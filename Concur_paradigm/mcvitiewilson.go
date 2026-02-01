package main

import (
	"log"
	"slices"
)

func offer(rid int, residents map[int]*Resident, programs map[string]*Program) {
	res, ok := residents[rid]
	if !ok {
		log.Fatal("Resident not found in map")
	}

	pid := ""

	for _, p := range res.rol {
		if _, ok := programs[p]; ok {
			pid = p
			break
		}
	}

	if pid == "" {
		res.matchedProgram = ""
	} else {
		evaluate(rid, pid, residents, programs)
	}
}

func least_preferred(p *Program) int {
	worst_res := p.matchedResidents[0]
	worstRank := slices.Index(p.rol, worst_res)

	for _, rid := range p.matchedResidents {
		rank := slices.Index(p.rol, rid)
		if rank > worstRank {
			worst_res = rid
			worstRank = rank
		}
	}

	return worst_res
}

func remove(slice []int, val int) []int {
	for i, v := range slice {
		if v == val {
			return append(slice[:i], slice[i+1:]...)
		}
	}
	return slice
}

func evaluate(rid int, pid string, residents map[int]*Resident, programs map[string]*Program) {
	r, ok := residents[rid]

	if !ok {
		log.Fatal("Error getting resident")
	}

	p, ok := programs[pid]

	if !ok {
		log.Fatal("Error getting program")
	}

	least_pref := least_preferred(p)

	if len(r.rol) == 0 {
		offer(rid, residents, programs)
	} else if len(p.matchedResidents) < p.nPositions {
		r.matchedProgram = pid
		p.matchedResidents = append(p.matchedResidents, rid)
	} else if slices.Index(p.rol, rid) < slices.Index(p.rol, least_pref) {
		p.matchedResidents = remove(p.matchedResidents, least_pref)
		p.matchedResidents = append(p.matchedResidents, rid)
		r.matchedProgram = pid
	} else {
		offer(rid, residents, programs)
	}
}
