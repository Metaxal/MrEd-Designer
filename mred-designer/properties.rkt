#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # properties.rkt                                                                 #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
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

(require "code-write.rkt"
         "misc.rkt")

; ************************
; * Property Definitions *
; ************************

;; Turns a "flat" value into a property<%> if it is not already one.
;; Defined for convenience when creating `property<%>'s.
(define/provide (flat-prop->prop val)
  (cond [(is-a? val property<%>) val]
        [(atom? val)
         (make-object prop:atom% val)]
        [(list? val)
         (make-object prop:atom% val)]  ;atom also ?
        [else
         (printf "flat-prop->prop: Don't know what to do with ~a\n" val)]
        )
  )

;; Returns a flat value, whatever is given.
(define/provide (prop->val p)
  (cond [(is-a? p property<%>)
         (send p get-value)]
        [(symbol? p) (list 'quote p)]
        [(list? p)   (cons 'list (map prop->val p))]
        [(path? p)   (path->string p)] ; or (cons 'build-path (map prop->val (explode-path p))) ??
        [else p]
        ))

(define/provide property<%>
  (interface () get-value generate-code))

(define (prop-value%% c%)
  (class* (code-write%% c%) (property<%>)
    (super-new)
    (init-field value)
    
    (code-fields value)
    
    (field [update-callback #f])

    ; Returns the value used to initialize the corresponding field
    ; for use inside MrEd Designer
    (define/public (get-value) 
      value
      )
    
    (define/public (set-value v)
      (set! value v)
      (update) ; ??
      )
    
    (define/public (generate-pre-code)
      '()
      )
    
    ; Returns the code that will be used in the generated code
    (define/public (generate-code)
      ; by default it is simply the value
      value
      ; but if this value can be of a more complex type (like a proc, a struct, etc.)
      ; then it must be written in a legible format.
      ; Symbols must be quoted.
      )
    
    (define/public (set-update-callback proc) 
      (set! update-callback proc)
      )
    
    (define/public (update)
      ; use a list of callbacks instead?
      (when update-callback (update-callback this)))
    ))

;; Default for ground values like numbers, symbols, etc.
(define prop:value%
  (class (prop-value%% object%)
    (super-new)
    
    (inherit-field value)
    (define/override (generate-code)
      (prop->val value))
;      (cond [(symbol? value) (list 'quote value)]
;            [(list? value) (cons 'list (map value)]
;            [else value]))
    ))

;; The property that holds the field-id and the associated property
;; field-id : symbol. Field id for the 'new' call in the generated code
;; option : bool. Is this field an option of the generated init function?
(define/provide prop:field-id%
  (class prop:value%
    (init-field field-id [option #f] [necessary #f] [no-code #f] [hidden #f])
    (code-fields field-id option necessary no-code hidden)
    (super-new)

    (getter field-id necessary no-code hidden)
    (getter/setter option)
    
    (inherit-field value)
    (define/public (get-prop) value)
    (define/override (get-value)
      (send value get-value))

    (define/override (update)
      (send value update))
    
    (define/override (generate-pre-code)
      (send value generate-pre-code))
    
    (define/public (option-symbol [prefix ""])
      (symbol-append* prefix field-id))
    (define/public (option-keyword [prefix ""])
      (symbol->keyword (option-symbol prefix)))
    (define/public (generate-option [prefix ""])
      (if option
          (list (option-keyword prefix)
                (list (option-symbol prefix) (send value generate-code)))
          '()))
    (define/override (generate-code [prefix ""])
      (if option 
          (option-symbol prefix)
          (send value generate-code)))
    ))

;; A specific class only for ground values.
;; 'class' must be used to create a real class.
;; (otherwise, the class name is wrong)
(define/provide prop:atom% 
  (class prop:value% (super-new)))
(define/provide (prop:atom v)
  (new prop:atom% [value v]))

;; To give a label to boolean values
;; (prop:bool "is checked?" #f)
(define/provide prop:boolean%
  (class prop:value%
    (init-field label)
    (code-fields label)
    (getter label)
    (super-new)))
(define/provide (prop:bool label v)
  (new prop:boolean% [label label] [value v]))

(define/provide prop:file% 
  (class prop:value% (super-new)
    (inherit-field value)
    (define/override (generate-code)
      (if (and value (use-runtime-paths?))
          (symbol-append* (send (current-property-mred-id) get-id)
                          "-runtime-path")
          (prop->val value)))
    (define/override (generate-pre-code)
      (if (and value (use-runtime-paths?))
          (list
           (list 'define-runtime-path (symbol-append* (send (current-property-mred-id) get-id)
                                                      "-runtime-path")
                 (prop->val value)))
          '()))
    ))
(define/provide (prop:file v)
  (new prop:file% [value v]))
    
(define/provide prop:one-of%
  (class prop:value%
    [init-field choices]
    (field [prop-choices choices])
    (super-new)
    
    (code-fields choices)
    (getter prop-choices)

    ))
(define/provide (prop:one-of choices val)
  (make-object prop:one-of% choices val))
 
#;(define prop:value-list%
  (class prop:value%
    (super-new)
    (inherit-field value)
    ; Returns the list of values, 
    ; so that it can be used as an init value in a make-object
    (define/override (get-value)
      (map-send get-value value))
    
    (define/override (generate-pre-code)
      (apply append
             (map-send generate-pre-code value)))
    
    ; Here value is a list of values!
    (define/override (generate-code)
      (cons 'list (map-send generate-code value)))
    
    ))

; choices : a list of flat values
; value : a list with some of the choices
(define/provide prop:some-of%
  (class prop:value%
    (init-field choices) 
    (super-new)
    (inherit-field value)

    (code-fields choices)
    (getter choices)
    
    (define/override (generate-code)
      (list 'quote value))
    ))
(define/provide (prop:some-of choices val-list)
  (make-object prop:some-of% choices val-list))

(define/provide prop:group%
  (class prop:value%
    (super-new)
    (inherit-field value)
    
    ; set-value : should not be used?
    
    (define/public (get-props) value)
    (define/override (get-value)
      (map-send get-value value))
    
    (define/override (generate-pre-code)
      (apply append (map-send generate-pre-code value)))
    
    (define/override (generate-code)
      (cons 'list (map-send generate-code value)))
    
    (define/override (update) ; useful??
      (for-each-send update value))
      
    ))
(define/provide (prop:group . vlist)
  ; be sure we have a list of property<%>
  (make-object prop:group% (map flat-prop->prop vlist)))

; Same as group, be useful for property-widgets
; -> horizontal panel group
(define/provide prop:hgroup% (class prop:group% (super-new)))
(define/provide (prop:hgroup . vlist)
  (make-object prop:hgroup% (map flat-prop->prop vlist)))

(define/provide prop:popup%
  (class prop:value%
    (super-new)
    (inherit-field value)
    (define/public (get-prop) value)
    (define/override (get-value)
      (send value get-value))
    
    (define/override (generate-pre-code)
      (send value generate-pre-code))
    
    (define/override (generate-code)
      (send value generate-code))
    (define/override (update)
      (send value update))
    ))
(define/provide (prop:popup val)
  (make-object prop:popup% (flat-prop->prop val)))

;; e.g., for callbacks and other procedures that need code and quoted-code
(define/provide prop:code%
  (class prop:value%
    (super-new)
    (init-field value-code)
    ;; value-code is the quoted version of value

    ;; cannot use code-fields per se becase we have a non-printable value.
    ;; so redefine how the argument list is printed.
    (define/override (code-write-args)
      (list (list 'value value-code)
            (list 'value-code (list 'quote value-code))))

    (setter value-code)

    (define/override (generate-code)
      value-code)
    ))

; Use these to create or modify a prop:code object!
(provide prop:code)
(define-syntax-rule (prop:code fun)
  (new prop:code% [value fun]
       [value-code 'fun]))
(provide prop:code-set-value)
(define-syntax-rule (prop:code-set-value prop fun)
  (begin
    ; do this one before:
    (send prop set-value-code 'fun)
    (send prop set-value fun)))

;; prop-code must be a prop:code%
(define/provide prop:proc%
  (class prop:value%
    (inherit-field value)
    (super-new)
    (init-field prop-code
                [generate-quoted-code #t]) 
    ; if #t, the generated code is not executed before writing the value to the file,
    ; but the code is written as is and will be executed when
    ; the generated code will be called.
    ; Example:
    ;  prop-code = (?(x)(+ x 1))
    ;  value: 4
    ;  if generate-quoted-code, the generated code is ((?(x)(+ x 1)) 4)
    ;  otherwise it is 5
    
    (code-fields prop-code generate-quoted-code)
    (setter prop-code)

    (define/public (get-prop) value)
    (define/override (get-value)
      ((send prop-code get-value) (send value get-value)))
    
    (define/override (generate-pre-code)
      (append
       (send prop-code generate-pre-code)
       (send value generate-pre-code)))
    
    (define/override (generate-code)
      (if generate-quoted-code
          (list (send prop-code generate-code)
                (send value generate-code))
          (get-value)
          ))
    ))
(provide prop:proc)
(define-syntax-rule (prop:proc v fun)
  (new prop:proc% [value (flat-prop->prop v)]
       [prop-code (prop:code fun)]))

(provide prop:proc-unquoted)
(define-syntax-rule (prop:proc-unquoted v fun)
  (new prop:proc% [value (flat-prop->prop v)]
       [prop-code (prop:code fun)]
       [generate-quoted-code #f]
       ))
