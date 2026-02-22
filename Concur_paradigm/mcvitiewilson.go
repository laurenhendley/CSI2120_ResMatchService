package main

// Imported packages
import (
	"log"
	"slices"
)

// Function to offer coures to the residents
func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {
	// Try to find the resident based on the id, throw error if not found
	res, ok := residents[rid]
	if !ok {
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
	} else {
		evaluate(rid, pid, residents, programs)
	}
}

// Find the least preferred resident
func least_preferred(p *Program) int {
	// Initialize
	worst_res := p.matchedResidents[0]
	worstRank := slices.Index(p.rol, worst_res)

	// For each resident in the matched residents
	for _, rid := range p.matchedResidents {
		// Find the rank
		rank := slices.Index(p.rol, rid)
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

	// If the program doesn't want the resident
	if slices.Index(p.rol, rid) == -1 {
		// Try the next program and remove current program
		r.rol = r.rol[1:]
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
			r.rol = r.rol[1:]
			offer(rid, residents, programs)
		}
	}
}
