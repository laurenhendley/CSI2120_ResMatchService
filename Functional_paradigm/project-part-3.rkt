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
      ((not (number? (car pinfo-res))) (traverse-pinfo-residents rid (cdr pinfo-res)))
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
 (cond ((null? (cdr matches)) (car matches))
      (else (let ((lp-rest (least-preferred (cdr matches))))
              (if (>= (cdr (car matches)) (cdr lp-rest))
                (car matches)
                lp-rest)))
  )
)

; HELPER - Updating matches

; Offer a program to a resident
(define (offer rinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) matches)
        (else
         (let* ((pid (car (cadddr rinfo)));the first line here is the top program choice
                (pinfo (get-program-info pid plist))
                (rid (car rinfo))
                (match (if (null? (get-match pid matches))
                          (list pid '()) (get-match pid matches)));this is the match for the program, if there is no match then we create a new one with an empty resident list
                (cur_res
                 (if (null? match) '() (cadr match)));added this which checks if the match is null, if it is it will get the next match
                (quota (if (null? pinfo) 0 (caddr pinfo)))
                (rank_res (if (null? pinfo) 0 (rank rid pinfo))))
         (cond ((null? pinfo)
                (offer (list (car rinfo) (cadr rinfo) (caddr rinfo) (cdr (cadddr rinfo))) rlist plist matches))
                ((< (length cur_res) quota) (offerHelper matches pid (add-resident-to-match (cons rid rank_res) match)))
               ((>= (length cur_res) quota) (evaluate rinfo pinfo rlist plist matches))))))
)

(define (offerHelper matches pid new-match) ;helper function to udpate the matches with the new program match
  (cond ((null? matches) (list new-match))
        ((equal? pid (car (car matches)))
         (cons new-match (cdr matches)))
        (else
         (cons (car matches) (offerHelper (cdr matches) pid new-match))))
)

; Evaluates whether a resident should be added based on their ranking
(define (evaluate rinfo pinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) matches)
        (else (let* ((pid (car (cadddr rinfo)));these are the definitions for variables that will be usedto evaluate the residents and the leastpreffered resident
                      (res_rank (rank (car rinfo) (get-program-info pid plist)))
                      (match (get-match pid matches))
                      (cur_res (if (null? match) '() (cadr match))); in case the match is null we set hte current resident list to empty
                      (lp (least-preferred cur_res))
                      (lp-rid (car lp))
                      (lp_rank (cdr lp)))
                (cond ((> res_rank lp_rank)
                      (offer (list (car rinfo) (cadr rinfo) (caddr rinfo) (cdr (cadddr rinfo))) rlist plist matches));this is if the resident is ranked higher than the least preferred resident, then we offer the program to this resident and remove the lp one
                      (else (let* ((new-res-list (remove-lp lp-rid cur_res));this is if the new resident is ranked lower than the least prefferered resident, the program is then offered to the least preferred resident
                                   (new-match (list pid (cons (cons (car rinfo) res_rank) new-res-list)))
                                   (new-matches (offerHelper matches pid new-match))
                                   (lp-rinfo (get-resident-info lp-rid rlist))
                                   (new-lp (list (car lp-rinfo) (cadr lp-rinfo) (caddr lp-rinfo) (cdr (cadddr lp-rinfo)))));calls offer on the least preferred resident to find them a new match
                              (offer new-lp rlist plist new-matches))))
                             
        ))
))

;Helper function to remove the least preferred resident from the match list
(define (remove-lp lp_rid cur_res)
  (cond ((null? cur_res) '())
        ((= (car (car cur_res)) lp_rid) (cdr cur_res))
        (else (cons (car cur_res) (remove-lp lp_rid (cdr cur_res)))))
)

;the call to the gale shapley function, this is where the main logic of the algorithm is implemented, it checks if the resident list is empty, if the resident is already matched, and then offers the program to the resident
(define (gale-shapley Rlist Plist matches)
  (cond ((null? Rlist) matches);base case if the resident list is empty, return the matches
        ((matched? (car (car Rlist)) matches) (gale-shapley (cdr Rlist) Plist matches)) ;if the resident is already matched, move on to the next resident
        (else (gale-shapley (cdr Rlist) Plist (offer (car Rlist) Rlist Plist matches)))
  )
)

;The few below functions are for thep rint of the program output

;Gets the list of unmatched residents
(define (get-not-matched-list rlist matches)
  (cond ((null? rlist) '())
        ((matched? (car (car rlist)) matches) (get-not-matched-list (cdr rlist) matches))
        (else (cons (car rlist) (get-not-matched-list (cdr rlist) matches)))
  )
)

;gets the total number of available positions by checking the quota for each program and subtracting the number of residents currently matched to that program
(define (get-total-available-positions matches plist)
  (define (filled-for pid)
    (let ((m (get-match pid matches)))
      (if (null? m) 0 (length (cadr m)))))
  (cond ((null? plist) 0)
        (else (let* ((pinfo (car plist))
                     (pid (car pinfo))
                     (quota (caddr pinfo))
                     (remaining (- quota (filled-for pid))))
                (+ remaining (get-total-available-positions matches (cdr plist)))))))


;This is waht prints the format of the matches, it gets the program information and then for each resident matched to that program it prints the resident information along with the program information
(define (display-program-matches match rlist plist)
  (let* ((pid (car match))
         (pinfo (get-program-info pid plist))
         (pname (cadr pinfo))
         (residents (cadr match)))
    (for-each (lambda (res)
                (let* ((rid (car res))
                       (rinfo (get-resident-info rid rlist)))
                  (display (caddr rinfo)) (display ",");last name
                  (display (cadr rinfo)) (display ",");first name
                  (display rid) (display ",");resident id
                  (display pid) (display ",");program id
                  (display pname) (newline)));name 
              residents)))

;This is what prints the format of the unmatchedresidents
(define (display-not-matched not-matched-list rlist)
  (for-each (lambda (res)
              (let* ((rid (car res))
                     (rinfo (get-resident-info rid rlist)))
                (display (caddr rinfo)) (display ",");last name
                (display (cadr rinfo)) (display ",");first name
                (display rid) (display ",");resident id
                (display "XXX") (display ",");XXX for the program id since they are unmatched
                (display "NOT_MATCHED") (newline)));A string to indicate that they are unmatched
            not-matched-list))

; Given code below


(define (gale-shapley-print rlist plist)
  (let* ((matches (gale-shapley rlist plist '()))
         (not-matched-list (get-not-matched-list rlist matches)))
      (for-each (lambda(m)
                  (display-program-matches m rlist plist)) matches)
      (display-not-matched not-matched-list rlist)
      (display "Number of unmatched residents: ")
      (display (length not-matched-list)) (newline)
      (display "Number of positions available: ")
      (display (get-total-available-positions matches plist))
      (newline)))
  

(define (read-f filename) (call-with-input-file filename
(lambda (input-port)
(let loop ((line (read-line input-port)))
(cond
 ((eof-object? line) '())
 (#t (begin (cons (string-split (clean-line line) ",") (loop (read-line input-port))))))))))

(define (format-resident lst)
  (list (car lst) (cadr lst) (caddr lst) (cdddr lst)))

(define (format-program lst)
  (list (car lst) (cadr lst) (string->number (caddr lst)) (map string->number(cdddr lst))))


(define (clean-line str)
  (list->string
   (filter (lambda (c) (not (or (char=? c #\") (char=? c #\[) (char=? c #\]) )))
           (string->list str))))

(define (read-residents filename)
(map (lambda(L) (format-resident (cons (string->number (car L)) (cdr L)))) (cdr (read-f filename))))

(define (read-programs filename)
(map format-program (cdr (read-f filename))))

(define PLIST (read-programs "programSmall.csv"))
(define RLIST (read-residents "residentSmall.csv"))


; Testing...

