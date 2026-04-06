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

(define (offer rinfo rlist plist matches))

(define (evaluate rinfo pinfo rlist plist matches))

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

