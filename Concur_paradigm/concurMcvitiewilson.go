package main

// Imported packages
import (
	"log"
	"sync"
)

// Function to offer coures to the residents
func ConcurOffer(rid int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup, mu *sync.Mutex) {
	// Defer completion
	defer wg.Done()

	ConcurEvaluate(rid, residents, programs, wg, mu)
}

// Evaluation function
func ConcurEvaluate(rid int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup, mu *sync.Mutex) {
	allRids := []int{rid}

	for len(allRids) > 0 {
		cur_rid := allRids[0]
		allRids = allRids[1:]

		// Try to find the resident based on the id, throw error if not found
		res, ok := residents[cur_rid]
		if !ok {
			log.Fatal("Resident not found in map")
		}

		match := false
		for len(res.rol) > 0 {
			pid := res.rol[0]
			res.rol = res.rol[1:]

			// Find the program id in the 'rol' of the resident
			p, ok := programs[pid]
			if !ok {
				log.Fatal("Program not found")
			}

			// If the program doesn't want the resident
			wants := false
			for _, res := range p.rol {
				if res == rid {
					wants = true
					break
				}
			}

			if !wants {
				continue
			}

			mu.Lock()
			// If there is still room for matched residents
			if len(p.matchedResidents) < p.nPositions {
				// Match the resident
				match = true
				res.matchedProgram = pid
				p.matchedResidents = append(p.matchedResidents, rid)
				mu.Unlock()
				break
			}

			least_pref := least_preferred(p)
			// Check if the new resident is ranked higher than worst
			rankRid := -1
			rankLeastPref := -1

			for i, j := range p.rol {
				if j == rid {
					rankRid = i
				}
				if j == least_pref {
					rankLeastPref = i
				}
			}

			if rankRid != -1 && rankLeastPref != -1 && rankRid < rankLeastPref {
				// Then replace them (remove worst resident)
				p.matchedResidents = remove(p.matchedResidents, least_pref)
				p.matchedResidents = append(p.matchedResidents, rid)
				res.matchedProgram = pid
				residents[least_pref].matchedProgram = ""
				allRids = append(allRids, least_pref)
				mu.Unlock()
				match = true
				break
			}
			mu.Unlock()
		}
		// If there's no program, match them with no program, otherwise find a program for them
		if !match {
			res.matchedProgram = ""
		}
	}
}
