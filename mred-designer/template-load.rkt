#lang racket

; Do not remove!
; All of these are needed for template loading
(require "properties.rkt"
         "mred-plugin.rkt"
         "mred-id.rkt"
         "default-values.rkt"
         "misc.rkt" ; for debug-printf
         racket/gui/base
         #;framework
         
         ; Yurk! Specific behavior!
         ; This SHOULD be generalized to all plugins!
         "widgets/project/preview.rkt" 
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
                (begin (printf "template-load-file: load done\n")
                       last-exp)
                (loop (eval exp ns))))))))
