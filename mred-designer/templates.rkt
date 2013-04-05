#lang racket

(require racket/gui/base
         "misc.rkt"
         "mred-id.rkt"
         "mred-plugin.rkt"
         "code-generation.rkt"
         "template-load.rkt"
         )

(module+ test
  (require rackunit))

(define template-dir (build-path "templates"))
;; Dictionary of (template-file . template-name)
(define/provide template-dict #f)
(define/provide (template-file f) (build-path template-dir f))

;; We should make a class for templates !
;; Avoid loading several times...

(define/provide (get-template-name file)
  (and (file-exists? file)
       (with-input-from-file file
         (λ()(let* ([name (read)])
               (and (string? name)
                    name))))
      ))

(define template-name-pattern
  "med-template-~a.med")

(define template-name-regexp
  (format (regexp-quote template-name-pattern) ".*"))
  
;; Call this function to set the template-dict to the correct value
;; or to update it (e.g., if the directory structure has changed)
(define/provide (make-template-dict)
  (set! template-dict
        (append-map (λ(f)
                      (let ([f (build-path template-dir f)])
                       (if (and (file-exists? f) ; it may be a directory
                                (regexp-match template-name-regexp (path->string f)))
                           (list (cons f (get-template-name f)))
                           '()
                           )))
                     (directory-list template-dir))))

(define (print-template mid name)
  ; writes the code that will be executed
  (write name) (newline)
  (parameterize ([print-as-expression #f])
    (pretty-print 
     `(list
       (cons 'name 
             ,name)
       (cons 'parent-class
             ,(send (send mid get-plugin) get-parent-widget-class-symbol))
       (cons 'med-version 
             ,(list 'list application-version-maj application-version-min))
       (cons 'code
             ,(write-mred-id-code mid))))))

(define/provide (save-template mid name [file #f])
  (debug-printf "save-template: ~a\n" name)
  (when name
    (let ([file (or file
                    (make-temporary-file template-name-pattern #f 
                                         template-dir))])
      ; write the name of the template
      (with-output-to-file file
        (λ() (print-template mid name))
        #:exists 'replace)
      ))
  (debug-printf "save-template: exit\n")
  )

; returns the result of executing the code stored in the template, or #f on error. 
(define/provide (load-template file parent-mid)
  (debug-printf "load-template: ~a\n" file)
  (and file
       (let ([dico (template-load-file file)])
         (debug-printf "load-template: load done\n")
         (when dico
           (let ([name (dict-ref dico 'name)]
                 [parent-class (dict-ref dico 'parent-class)]
                 [med-version (dict-ref dico 'med-version #f)] ; if not found (#f), then file was created with version < 3.9
                 [proc (dict-ref dico 'code)])
             (if med-version
                (printf "MED template version: ~a\n" med-version)
                (printf "No MED template version found\n"))
             (and (check-template-version med-version)
                  (procedure? proc)
                  (equal? (procedure-arity proc) 1)
                  (or (can-instantiate-under? parent-mid parent-class)
                      (begin 
                        (printf "Cannot insert template at this node\n") 
                        #f))
                  (proc parent-mid)
                  )
             )))
       )
  )

(define/provide (delete-template file)
  (when file
    (delete-file file)))
    
(define (newer-version-than-current? vers)
  (and vers
       (or (> (first vers) application-version-maj)
           (and (= (first vers) application-version-maj)
                (> (second vers) application-version-min)))))

(define (check-template-version vers)
    (or (not (newer-version-than-current? vers))
        (eq? 
 'yes
 (message-box "Object created with newer version" 
              (format "The object you are loading was made with version ~a.~a of ~a which is newer than you current version ~a.~a. There may be problems loading it. Do you still want to proceed?" 
                      (first vers) (second vers)
                      application-name
                      application-version-maj application-version-min)
              #f '(yes-no)))))



