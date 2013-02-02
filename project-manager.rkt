#lang racket

;;; Use (make-plt) to create the archive
;;; see instructions at the bottom of this page

(require planet/util
         racket/system
         "mreddesigner-misc.rkt"
         )

; delete .bak files
; delete .svn dirs
; delete tests folder
; delete compiled folders

(define (ok) (printf "OK\n"))

(define (regexp-find-files pattern [type 'both])
  (find-files
   (λ(f)(and (or (and (equal? type 'dir) (directory-exists? f))
                 (and (equal? type 'file) (file-exists? f))
                 (equal? type 'both))
             (regexp-match 
              pattern
              (path->string f))
             f))
   (build-path ".")
   ))

(define (file-pattern->regexp pattern)
  (let* ([pattern (string-append "^" pattern "$")]
         [pattern (regexp-replace* "\\." pattern "\\\\.")]
         ;[_ (printf "p: ~s~n" pattern)]
         [pattern (regexp-replace* "\\*" pattern ".*")]
         ;[_ (printf "p: ~s~n" pattern)]
         [pattern (regexp-replace* "/" pattern "\\\\\\\\")]
         ;[_ (printf "p: ~s~n" pattern)]
         )
    pattern
    ))

(define (pattern-find-files pat [type 'both])
  (regexp-find-files 
   (file-pattern->regexp pat)
   type
   ))
  

(define (safe-delete paths)
  (unless (empty? paths)
    (printf "Are you sure you want to delete these paths (yes/no)?\n")
    (pretty-print paths)
    (newline)
    (let ([res (read-line)])
      (when (equal? res "yes")
        (printf "Deleting...")
        (map delete-directory/files paths)
        (ok)
        ))))


(define (tild-files)
  (pattern-find-files "*.*~" 'file))

(define (bak-files)
  (pattern-find-files "*.bak" 'file))

(define (svn-dirs)
  (pattern-find-files "*/.svn" 'dir))

(define (compiled-dirs)
  (pattern-find-files "*/compiled" 'dir))

(define (test-dirs)
  (pattern-find-files "*/test*" 'dir))

(define (clean-project)
  (safe-delete (compiled-dirs)))



;; Prepare the project to make a package. 
(define (strip-project)
  (clean-project) ; remove "compiled" directories
  (safe-delete (tild-files))
  (safe-delete (bak-files))
  (safe-delete (test-dirs))
  (safe-delete (svn-dirs))
  )

(define (make-plt)
  (safe-delete (bak-files))
  (safe-delete (tild-files))
  (make-planet-archive 
   (current-directory)
   (build-path (current-directory) 'up
               "mred-designer.plt")
   ))

(define (planet-exe-str)
  (string-append 
   "\""
   (path->string (build-path (path-only (find-system-path 'exec-file)) "planet"))
   "\""))

; DO NOT USE!
(define (inject-pkg)
  (system
   (string-append 
    (planet-exe-str) " fileinject "
    (format " ~a ~a ~a ~a" 
            "orseau" "..\\mred-designer.plt" 
            application-version-maj application-version-min))))
;  (install-pkg
;   (get-package-spec "orseau"
;                     "mred-designer.plt"
;                     application-version-maj application-version-min)
;   "../mred-designer.plt" ;; this is the .plt file (here as a relative path)
;   application-version-maj application-version-min))

; undocumented function that could be used:
; (install-pkg pkg path maj min)

; PREFER the command line version...
(define (remove-package)
;  (remove-pkg "orseau" "mred-designer.plt" application-version-maj application-version-min))
  (system
   (string-append 
    (planet-exe-str) " remove "
    (format " ~a ~a ~a ~a" 
            "orseau" "mred-designer.plt" 
            application-version-maj application-version-min))))


(module+ main
  (printf "Please verify:
  - version number in mreddesigner-misc.rkt
  - Changelog
  - info.rkt
  ")
  (printf "Creating plt archive... ")
  (make-plt)
  (printf "Done.\n")
  )

; Just use:
; $ racket -t project-manager.rkt
; on the command line.


; 1) Change version in "mreddesigner-misc.rkt", and below:
; 2) Update "info.rkt"
; 3) (define pkg (make-plt))
; 4) (system "\"c:\\Program Files\\Racket\\planet\" fileinject orseau ../mred-designer.plt 3 3")
; OU: (system "planet fileinject orseau ../mred-designer.plt 3 8")
; 5) in an empty interaction window: (require (planet orseau/mred-designer))
; 6) (system "\"c:\\Program Files\\Racket\\planet\" remove orseau mred-designer.plt 3 3")
; OU: (system "planet remove orseau mred-designer.plt 3 8")

