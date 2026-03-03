//Students:
//Lauren Hendley [lhend093@uottawa.ca, SN: 300405588]
//Acadia Marchand [amarc139@uottawa.ca, SN: 300340641]

package main

// Imported packages
import (
	"log"
)

// Function to offer coures to the residents
func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {
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

			// If there is still room for matched residents
			if len(p.matchedResidents) < p.nPositions {
				// Match the resident
				match = true
				res.matchedProgram = pid
				p.matchedResidents = append(p.matchedResidents, rid)
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
				match = true
				break
			}
		}
		// If there's no program, match them with no program, otherwise find a program for them
		if !match {
			res.matchedProgram = ""
		}
	}
}

// Find the least preferred resident
func least_preferred(p *Program) int {
	// Initialize
	worst_res := p.matchedResidents[0]
	worstRank := -1
	for i, v := range p.rol {
		if v == worst_res {
			worstRank = i
			break
		}
	}

	// For each resident in the matched residents
	for _, rid := range p.matchedResidents {
		// Find the rank
		rank := -1
		for i, v := range p.rol {
			if v == rid {
				rank = i
				break
			}
		}
		// Replace if it's worse
		if rank > worstRank {
			worst_res = rid
			worstRank = rank
		}
	}

	return worst_res
}

// Helper remove function
func remove(slice []int, val int) []int {
	// Make the resulting slice
	res := make([]int, 0, len(slice)-1)

	// Append all values except desired deleted value
	for _, v := range slice {
		if v != val {
			res = append(res, v)
		}
	}
	return res
}

/*
// Evaluation function
func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program) {
	// Find resident, throw error if not found
	r, ok := residents[rid]
	if !ok {
		log.Fatal("Error getting resident")
	}

	// Find program, throw error if not found
	p, ok := programs[pid]
	if !ok {
		log.Fatal("Error getting program")
	}

	// Skip current program
	r.rol = r.rol[1:]

	// If the program doesn't want the resident
	if slices.Index(p.rol, rid) == -1 {
		// Try the next program
		offer(rid, residents, programs)
		return
	}

	// If there is still room for matched residents
	if len(p.matchedResidents) < p.nPositions {
		// Match the resident
		r.matchedProgram = pid
		p.matchedResidents = append(p.matchedResidents, rid)
	} else { // Otherwise, check if its preferred more than someone else
		least_pref := least_preferred(p)

		// Check if the new resident is ranked higher than worst
		if slices.Index(p.rol, rid) < slices.Index(p.rol, least_pref) {
			// Then replace them (remove worst resident)
			p.matchedResidents = remove(p.matchedResidents, least_pref)
			p.matchedResidents = append(p.matchedResidents, rid)
			r.matchedProgram = pid
			residents[least_pref].matchedProgram = ""
			offer(least_pref, residents, programs)
		} else {
			// Otherwise, resident applies to next choice
			offer(rid, residents, programs)
		}
	}
}
*/
