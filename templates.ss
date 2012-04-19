#lang scheme

(require "mreddesigner-misc.ss"
         "mred-id.ss"
         "mred-plugin.ss"
         "code-generation.ss"
         "template-load.ss"
         )

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

(define/provide (save-template mid name [file #f])
  (debug-printf "save-template: ~a\n" name)
  (when name
    (let ([file (or file
                    (make-temporary-file template-name-pattern #f 
                                         template-dir))])
      ; write the name of the template
      (with-output-to-file file
        (λ()
          ; writes the code that will be executed
          (write name) (newline)
          (pretty-print 
           `(list
                 (cons 'name 
                       ,name)
                 (cons 'parent-class
                       ,(send (send mid get-plugin) get-parent-widget-class-symbol))
                 (cons 'code
                       ,(write-mred-id-code mid)))))
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
                 [proc (dict-ref dico 'code)])
             (and (procedure? proc)
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
