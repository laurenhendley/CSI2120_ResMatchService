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
	res := make([]int, 0, len(slice)-1)
	for _, v := range slice {
		if v != val {
			res = append(res, v)
		}
	}
	return res
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

	if slices.Index(p.rol, rid) == -1 {
		r.rol = r.rol[1:]
		offer(rid, residents, programs)
		return
	}

	if len(p.matchedResidents) < p.nPositions {
		r.matchedProgram = pid
		p.matchedResidents = append(p.matchedResidents, rid)
	} else {
		least_pref := least_preferred(p)
		if slices.Index(p.rol, rid) < slices.Index(p.rol, least_pref) {
			p.matchedResidents = remove(p.matchedResidents, least_pref)
			p.matchedResidents = append(p.matchedResidents, rid)
			r.matchedProgram = pid
			residents[least_pref].matchedProgram = ""
			offer(least_pref, residents, programs)
		} else {
			r.rol = r.rol[1:]
			offer(rid, residents, programs)
		}
	}
}
