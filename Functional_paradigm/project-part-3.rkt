#lang racket
; McVitie Wilson implementation

; Getting the resident information
(define (get-resident-info rid rlist)
  (cond ((null? rlist) null)
        (( = (car(car rlist)) rid) (car rlist))
        (else (get-resident-info rid (cdr rlist)))
  )
)

; Getting the program information
(define (get-program-info pid plist)
  (cond ((null? plist) null)
        ((equal? (car(car plist)) pid) (car plist))
        (else (get-program-info pid (cdr plist)))
  )
)

; HELPER - traverses resident list
(define (traverse-pinfo-residents rid pinfo-res)
  (cond ((null? pinfo-res) 0)
        ((= rid (car pinfo-res)) 0)
        (else (+ 1 (traverse-pinfo-residents rid (cdr pinfo-res))))
))

; Getting the rank of a resident (0-based)
(define (rank rid pinfo)
  (traverse-pinfo-residents rid (cadddr pinfo))
)

; HELPER - traverses a program list
(define (traverse-program-list rid program-list)
  (cond ((null? program-list) #f)
        ((= (car (car program-list)) rid) #t)
        (else (traverse-program-list rid (cdr program-list)))
  )
)

; Checking if a user is matched
(define (matched? rid matches)
  (cond ((null? matches) #f)
        ((traverse-program-list rid (cadr(car matches))) #t)
        (else (matched? rid (cdr matches)))
  )
)

; Gets the match information
(define (get-match pid matches)
  (cond ((null? matches) null)
        ((equal? pid (car(car matches))) (car matches))
        (else (get-match pid (cdr matches)))
  )
) 

; Adds resident to the match list
(define (add-resident-to-match pair match)
  (list (car match) (cons pair (cadr match)))
)

; Getting least preferred
(define (least-preferred matches)
  (cond ((null? matches) null)
        (else (car matches))
  )
)

; HELPER - Updating matches

; Offer a program to a resident
(define (offer rinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) matches)
        (else
              (let* ((pid (car (cadddr rinfo)))
                     (pinfo (get-program-info pid plist))
                     (match (get-match pid matches))
                     (rank_res (rank (car rinfo) (get-program-info pid plist)))
                     (quota (caddr pinfo))
                     (cur_res (cadr match))
                     (rid (car rinfo)))
                (cond ((< (length cur_res) quota) (add-resident-to-match (cons rid rank_res) match))
                      ((>= (length cur_res) quota) (evaluate rinfo pinfo rlist plist matches)))
  ))
))

; Evaluates whether a resident should be added based on their ranking
(define (evaluate rinfo pinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) matches)
        (else (let * ((pid (car (cadddr rinfo)))
                      (res_rank (rank (car rinfo) (get-program-info pid plist)))
                      (match (get-match pid matches))
                      (cur_res (cadr match))
                      (lp (least-preferred cur_res))
                      (lp_rank (cdr lp)))
                (cond ((< lp_rank res_rank) ())
                      (else ()))
        ))
))

(define (gale-shapley))


; Given code below

(define PLIST (read-programs "programSmall.csv"))
(define RLIST (read-residents "residentSmall.csv"))

(define (gale-shapley-print rlist plist)
  (let* ((matches (gale-shapley rlist plist '()))
         (not-matched-list (get-not-matched-list rlist matches))
      (for-each (lambda(m)
                  (display-program-matches m rlist plist)) matches)
      (display-not-matched not-matched-list rlist)
      (display "Number of unmatched residents: ")
      (display (length not-matched-list)) (newline)
      (display "Number of positions available: ")
      (display (get-total-available-positions matches plist))
      (newline))))
  
(gale-shapley-print RLIST PLIST)



; Testing...

