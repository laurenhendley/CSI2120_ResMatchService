package main

// Imported packages
import (
	"log"
	"slices"
	"sync"
)

// Function to offer coures to the residents
func ConcurOffer(rid int, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup, mu *sync.Mutex) {
	// Defer completion
	defer wg.Done()

	mu.Lock()

	// Try to find the resident based on the id, throw error if not found
	res, ok := residents[rid]
	if !ok {
		mu.Unlock()
		log.Fatal("Resident not found in map")
	}

	// Find the program id in the 'rol' of the resident
	pid := ""
	for _, p := range res.rol {
		if _, ok := programs[p]; ok {
			pid = p
			break
		}
	}

	// If there's no program, match them with no program, otherwise find a program for them
	if pid == "" {
		res.matchedProgram = ""
		mu.Unlock()
	} else {
		mu.Unlock()
		ConcurEvaluate(rid, pid, residents, programs, wg, mu)
	}
}

// Evaluation function
func ConcurEvaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program, wg *sync.WaitGroup, mu *sync.Mutex) {
	mu.Lock()

	// Find resident, throw error if not found
	r, ok := residents[rid]
	if !ok {
		mu.Unlock()
		log.Fatal("Error getting resident")
	}

	// Find program, throw error if not found
	p, ok := programs[pid]
	if !ok {
		mu.Unlock()
		log.Fatal("Error getting program")
	}

	// Skip current program
	r.rol = r.rol[1:]

	// If the program doesn't want the resident
	if slices.Index(p.rol, rid) == -1 {
		mu.Unlock()
		// Try the next program
		// Add operation to the waitGroup
		wg.Add(1)
		go ConcurOffer(rid, residents, programs, wg, mu)
		return
	}

	// If there is still room for matched residents
	if len(p.matchedResidents) < p.nPositions {
		// Match the resident
		r.matchedProgram = pid
		p.matchedResidents = append(p.matchedResidents, rid)

		mu.Unlock()
		return
	} else { // Otherwise, check if its preferred more than someone else
		least_pref := least_preferred(p)

		// Check if the new resident is ranked higher than worst
		if slices.Index(p.rol, rid) < slices.Index(p.rol, least_pref) {
			// Then replace them (remove worst resident)
			p.matchedResidents = remove(p.matchedResidents, least_pref)
			p.matchedResidents = append(p.matchedResidents, rid)
			r.matchedProgram = pid
			residents[least_pref].matchedProgram = ""

			// Call offer function concurrently
			mu.Unlock()
			wg.Add(1)
			go ConcurOffer(least_pref, residents, programs, wg, mu)
		} else {
			// Otherwise, resident applies to next choice
			// Call offer function concurrently
			mu.Unlock()
			wg.Add(1)
			go ConcurOffer(rid, residents, programs, wg, mu)
		}
	}
}
