#lang scheme

; For template loading
(require "properties.ss"
         "mred-plugin.ss"
         "mred-id.ss"
         "default-values.ss"
         "mreddesigner-misc.ss" ; for debug-printf
         scheme/gui/base
         framework 
         
         ; Yurk! Specific behavior!
         ; This SHOULD be generalized to all plugins!
         "widgets/project/preview.ss" 
         ; needed because of parent-class of frame
         ; which contains `project%'
         )

; Cannot (dunno how to) use 'load' without the top-level-interaction
; So use eval and a namespace anchor instead.
; This is not so bad because templates are not stand-alone modules,
; and are intended to be loaded in the current namespace.
(define-namespace-anchor nsa)
(define ns (namespace-anchor->namespace nsa))

; Returns the result of the last evaluated expression in the file
(provide template-load-file)
(define (template-load-file file)
  (debug-printf "template-load-file: load ~a\n" file)
  (with-input-from-file file
    (λ()(let loop ([last-exp (void)])
          (let ([exp (read)])
            ;(printf "read: ~a~n" exp)
            (if (eof-object? exp)
                (begin
                  (printf "template-load-file: load done\n")
                  last-exp
                  )
                (loop (eval exp ns)))))
      ))
  )
