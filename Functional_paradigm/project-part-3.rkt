#lang racket
; McVitie Wilson implementation

; Getting the resident information
(define (get-resident-info rid rlist)
  (cond ((null? rlist) null) ; returns null if null list
        (( = (car(car rlist)) rid) (car rlist)) ; checks if it found the resident
        (else (get-resident-info rid (cdr rlist))) ; otherwise continue through
  )
)

; Getting the program information
(define (get-program-info pid plist)
  (cond ((null? plist) null) ; returns null if null program list
        ((equal? (car(car plist)) pid) (car plist)) ; checks if it found the program
        (else (get-program-info pid (cdr plist))) ; otherwise continue through
  )
)

; HELPER - traverses resident list
(define (traverse-pinfo-residents rid pinfo-res)
  (cond ((null? pinfo-res) 0) ; returns 0 if null program info.
      ((not (number? (car pinfo-res))) (traverse-pinfo-residents rid (cdr pinfo-res))) 
      ((= rid (car pinfo-res)) 0) ; if found resident, return 0
      (else (+ 1 (traverse-pinfo-residents rid (cdr pinfo-res)))) ; sum to get rank
))

; Getting the rank of a resident (0-based)
(define (rank rid pinfo)
  (traverse-pinfo-residents rid (cadddr pinfo))
)

; HELPER - traverses a program list
(define (traverse-program-list rid program-list)
  (cond ((null? program-list) #f) ;returns false if the program list is null
        ((= (car (car program-list)) rid) #t); returns true if the resident is found in the rpogram list
        (else (traverse-program-list rid (cdr program-list))) ;otherwise it continues through the rest of the program list
  )
)

; Checking if a user is matched
(define (matched? rid matches)
  (cond ((null? matches) #f);returns false if the matches list is null
        ((traverse-program-list rid (cadr(car matches))) #t);returns true if the resident is found in the current match list
        (else (matched? rid (cdr matches))) ;otherwise it continues through the rest of the matches list
  )
)

; Gets the match information
(define (get-match pid matches)
  (cond ((null? matches) null);returns null if the mathes list is null
        ((equal? pid (car(car matches))) (car matches));returns the match if the program id is found in the matches list
        (else (get-match pid (cdr matches)));otherswise it continues through the rest of the matches list
  )
) 

; Adds resident to the match list
(define (add-resident-to-match pair match)
  (list (car match) (cons pair (cadr match)))
)

; Getting least preferred
(define (least-preferred matches)
 (cond ((null? (cdr matches)) (car matches));if the rest of the matches is null we return the first match since it is the least preferred
      (else (let ((lp-rest (least-preferred (cdr matches))));this is the least preferred resident for the rest of the matches
              (if (>= (cadr (car matches)) (cadr lp-rest));if the rank of the current match is greater or equal to the rank of the lp-rest then we return lp-rest
                (car matches);otherwise we return the current first match since it is less preferred than the lp-rest
                lp-rest)))
  )
)

; Offer a program to a resident
(define (offer rinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) (cons matches rlist))
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
         (cond ((null? pinfo);if the program info is null then we call offer on the next program choice for the resident and update the resident list
                (offer (list (car rinfo) (cadr rinfo) (caddr rinfo) (cdr (cadddr rinfo))) rlist plist matches))
                ((< (length cur_res) quota) (cons (offerHelper matches pid (add-resident-to-match (list rid rank_res (cdr (cadddr rinfo))) match)) (update-the-rlist rinfo rlist)))
                ((>= (length cur_res) quota) (evaluate rinfo pinfo rlist plist matches))))))
)

; HELPER - updating rlist
(define (update-the-rlist rinfo rlist)
  (map (lambda (res) (if (= (car res) (car rinfo)) rinfo res)) rlist)
)


;helper function to udpate the matches with the new program match
(define (offerHelper matches pid new-match)
  (cond ((null? matches) (list new-match));if the matches list is null we create a new match list with the new match
        ((equal? pid (car (car matches))) ;if the program id of the first match is equal to the pid we want to update then we update the match with the new match
         (cons new-match (cdr matches)));construct a new matches list with the new match and the rest of the matches
        (else
         (cons (car matches) (offerHelper (cdr matches) pid new-match))));otherwise kee pthe first match and continue throug the rest of the matches list
)

; Evaluates whether a resident should be added based on their ranking
(define (evaluate rinfo pinfo rlist plist matches)
  (cond ((null? (cadddr rinfo)) (cons matches rlist))
        (else (let* ((pid (car (cadddr rinfo)));these are the definitions for variables that will be usedto evaluate the residents and the leastpreffered resident
                      (res_rank (rank (car rinfo) (get-program-info pid plist)))
                      (match (get-match pid matches))
                      (cur_res (if (null? match) '() (cadr match)))); in case the match is null we set hte current resident list to empty
                      
                (cond ;this is the main evalution, if the current resident list is null then we add the resident to the match
                  ((null? cur_res) (cons (offerHelper matches pid (add-resident-to-match (list (car rinfo) res_rank (cdr (cadddr rinfo))) (list pid '()))) (update-the-rlist rinfo rlist)))
                  (else (let* ((lp (least-preferred cur_res));otherswise we get the least preferred resident from the current resident list
                               (lp-rid (car lp))
                               (lp_rank (cadr lp)))
                      (cond ((> res_rank lp_rank) ;compare the rank of the new resident with the least preffered resident
                      (offer (list (car rinfo) (cadr rinfo) (caddr rinfo) (cdr (cadddr rinfo))) (update-the-rlist rinfo rlist) plist matches));this is if the resident is ranked higher than the least preferred resident, then we offer the program to this resident and remove the lp one
                      (else (let* ((new-res-list (remove-lp lp-rid cur_res));this is if the new resident is ranked lower than the least prefferered resident, the program is then offered to the least preferred resident
                                   (new-match (list pid (cons (list (car rinfo) res_rank (cdr (cadddr rinfo))) new-res-list)))
                                   (new-matches (offerHelper matches pid new-match))
                                   (lp-remaining (caddr lp))
                                   (lp-rinfo (get-resident-info lp-rid rlist))
                                   (new-lp (list (car lp-rinfo) (cadr lp-rinfo) (caddr lp-rinfo) lp-remaining)));calls offer on the least preferred resident to find them a new match
                              (offer new-lp (update-the-rlist rinfo rlist) plist new-matches)))))))
                             
        ))
))

; Helper function to remove the least preferred resident from the match list
(define (remove-lp lp_rid cur_res)
  (cond ((null? cur_res) '());if the current resident list is null we return an empty list
        ((= (car (car cur_res)) lp_rid) (cdr cur_res));if hte current resident is the least preferred resident we remove it by returning the rest of the list
        (else (cons (car cur_res) (remove-lp lp_rid (cdr cur_res)))));otherwise we keep the first resident and continue throuygh the rest of the resident list to find the least preferred resident to remove
)

; the call to the gale shapley function, this is where the main logic of the algorithm is implemented, it checks if the resident list is empty, if the resident is already matched, and then offers the program to the resident
(define (gale-shapley Rlist Plist matches)
  (gale-shapley-helper Rlist Rlist Plist matches))

; HELPER for gale shapley
(define (gale-shapley-helper to-add Rlist Plist matches)
  (cond ((null? to-add) matches) ;if the list of residents to add is null we return the matches
        ((or (matched? (caar to-add) matches) (null? (cadddr (car to-add)))) (gale-shapley-helper (cdr to-add) Rlist Plist matches));if the resident is already matched or if the resident has no more program choices then we skip this resident and continue with the rest of the residents to add
        (else  (let* ((res (offer (car to-add) Rlist Plist matches));otherwise we offer the program to the resident and get the new matches and the new resident list
              (new-matches (car res))
              (new-rlist (cdr res)))
        (gale-shapley-helper (cdr to-add) new-rlist Plist new-matches));calls the helper on the rest of the residents
   ))
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


; The code below was given code

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

(define PLIST (read-programs "programs4000.csv"))
(define RLIST (read-residents "residents4000.csv"))
