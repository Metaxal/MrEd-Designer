#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # code-write.rkt                                                                 #
;; # http://mred-designer.origo.ethz.ch                                             #
;; # Copyright (C) Laurent Orseau, 2010                                             #
;; # ============================================================================== #
;; #                                                                                #
;; # This program is free software; you can redistribute it and/or                  #
;; # modify it under the terms of the GNU General Public License                    #
;; # as published by the Free Software Foundation; either version 2                 #
;; # of the License, or (at your option) any later version.                         #
;; #                                                                                #
;; # This program is distributed in the hope that it will be useful,                #
;; # but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
;; # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
;; # GNU General Public License for more details.                                   #
;; #                                                                                #
;; # You should have received a copy of the GNU General Public License              #
;; # along with this program; if not, write to the Free Software                    #
;; # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.    #
;; #                                                                                #
;; ##################################################################################

(require "mreddesigner-misc.rkt") ; for write-path

(provide code-write-value 
         code-write%%
         code-write<%>
         code-fields
         make-code-write-stub
         )

;;; Needs MzScheme 4.2.4 at least (for `this%')

;;; This module provides bindings to make class instances
;;; be able to write code that when evaluated generates a
;;; object with the same values as the written one.
;;; Like serialization, but writes (prints) racket code instead of values.
;;; Unlike serialization, it works also for classes that have fields that don't have default values!

;;; The main function to call on any value is (code-write-value something)
;;; Do not call (send obj code-write) ! Dependencies would not be correctly handled.

;;; Handles hierarchical dependencies but not cyclic dependencies.

;;; In case there must be a special treatment for some fields,
;;; the code-write-args method can be overriden.
;;; (super code-write-args) returns the list 
;;; to which must be appended new field-value pairs.

;;; code-write-value can be used on non-object values.
;;; Can be useful when overriding code-write-args.



(define code-write<%>
  (interface () code-write))
  
;; Turns a '<class:something%> into 'something%
(define (class-symbol cl)
  (let ([str (format "~a" cl)])
    (string->symbol
     (substring str
                8
                (- (string-length str) 1)))))

(define current-code-dict (make-parameter #f))
(define (make-code-dict) '())
(define (code-set! key val)
  (current-code-dict (dict-set (current-code-dict) key val)))
(define (code-remove! key)
  (current-code-dict (dict-remove (current-code-dict) key)))
(define (code-ref key proc/val)
  (dict-ref (current-code-dict) key 
            (if (procedure? proc/val) (proc/val) proc/val)))
(define NO-CODE-KEY-FOUND (gensym))
(define (code-ref! key val-default-proc)
  (let ([val (dict-ref (current-code-dict) key (λ()NO-CODE-KEY-FOUND))])
    (if (eq? val NO-CODE-KEY-FOUND)
        (let ([val (val-default-proc)])
          (code-set! key val)
          val)
        val)))

;; Main function to call with ground values or code-write<%> objects.
;; Can only handle hierarhical dependencies and not cycles.
;; (this would need to mutate the created values, using field-set?)
;; Returns the generated code that, when, loaded, recreates a value to the same.
;; If get-dict? is #t, it also returns the resulting dictionary that holds
;; the (id generaete-code) pairs (value) corresponding to the objects (key).
;; Use dict-ref on it.
(define (code-write-value val [get-dict? #f])
  (let ([top (not (current-code-dict))])
    (if top
        (parameterize ([current-code-dict (make-code-dict)])
          (let* ([code (code-write-value-aux val)]
                 ; generate all the let* bindings
                 ; they should be in the right order
                 [code (list 'let* (dict-map (current-code-dict)
                                             (λ(key val) val))
                             code)])
            (if get-dict?
                ; in case we'd like to get the resulting dictionary:
                (values code (current-code-dict))
                ; otherwise, just return the code:
                code)))
        ; else only return the value without parameterizing the dict
        (code-write-value-aux val)
        )))
        

(define (code-write-value-aux val)
  (cond [(is-a? val code-write<%>)
         (let ([code/val (code-ref val #f)]) ; #f is ok because we store lists
           (if code/val 
               (first code/val)
               (let ([name (gensym 'code-)])
                 ; first, we make sure we now have a name 
                 (code-set! val (list name #f))
                 ; now we can make the recursive call:
                 (let ([res (send val code-write)])
                   (code-remove! val)
                   ; so that the entry is placed *at the end* of the dict:
                   (code-set! val (list name res))
                   )
                 ; the we return the name
                 name)))]
        [(list? val)
         (cons 'list (map code-write-value val))]
        [(pair? val)
         (list 'cons (code-write-value (car val))
               (code-write-value (cdr val)))]
        [(path? val) ; need to make a special constructor for paths! (because they cannot be read by the reader)
         (write-path val)]
        [else (list 'quote val)]))

;; Use this macro only once in a class to add 
;; fields to be code-written.
;; No need to (and do not) give the fields that were given
;; in the super class.
(define-syntax-rule (code-fields arg ...)
  (begin (define/override (code-write-args)
           (append (super code-write-args)
                   (list (list 'arg 
                               (code-write-value arg))
                         ...)))
         ))
        
;; The mixin to be applied to the top level class of the class hierarchy
;; call (send obj code-write) to write the code that would recreate the object.
;; code-write-args is meant to be used internally only.
(define (code-write%% %)
  (class* % (code-write<%>)
    (super-new)
    (define/public (code-write-args) '())
    (define/public (code-write)
      (append (list 'new (class-symbol this%))
              (send this code-write-args)))
    ))

;; A stub to replace the default behavior of writing the creation
;; of an object.
;; Instead, this one will merely write a single value.
;; Replace the object value with such a stub for code-generation,
;; then replace it back with its real value.
;; (We could make a parameter for this or  something automatic,
;; like 'parameterize-code-write-object' ?)
(define code-write-stub%
  (class (code-write%% object%)
    (init-field value)
    (super-new)
    ;; The only thing that will be written in the code is the value:
    (define/override (code-write)
      value)
    ))
(define (make-code-write-stub value)
  (new code-write-stub% [value value]))

;(define-syntax-rule (code-write-parameterize ([obj val] ...) body ...)
;  ( ; needs generate-temporaries....

#| TESTS | #
(define a%
  (class (code-write%% object%) ; a% instances will be code-writable
    (super-new)
    (init [(_z z)]) ; order is not important
    (init-field x [y 0]) ; with default values or not
    (define z _z) ; works also with non-field attributes
    ; but the external name must be the same as the internal one
    (code-fields x y z) ; define code-writable fields 
    
    ))

(define b%
  (class a% ; derives from a code-write<%> class
    (super-new)
    (init-field w)
    (code-fields w) ; add code-writable fields to tha one already defined in the super class
    (define/public (set-w _w) (set! w _w))
    
    ))
      

(define a1 (new a% [x 1][y 2][z 3]))
(define a2 (new a% [x 10][y 20][z a1]))
(define b1 (new b% [x 6][y 7][z 8] [w 12]))
; test mutation + recurrent code-write :
(send b1 set-w (list 5 a2))
; write the code that defines b1 :
(code-write-value b1 #t)
;|#
