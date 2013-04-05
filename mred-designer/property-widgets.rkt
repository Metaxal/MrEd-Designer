#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # property-widgets.rkt                                                           #
;; # http://mred-designer.origo.ethz.ch                                             #
;; # Copyright (C) Laurent Orseau, 2010-2013                                        #
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


(require "properties.rkt"
         "mred-plugin.rkt"
         "tooltip.rkt"
         "widgets.rkt"
         "misc.rkt"
         ;"mreddesigner-properties-widget.rkt"
         "edit-list.rkt"
         "default-values.rkt"
         )

; ********************
; * Property-widgets *
; ********************

;;; TODO:
;;; - add a label to any prop, with a #:label options on the constructor.
;;;   could be used to add a label to popups, checkboxes, etc.
;;; - check-box-text-field widget: #f if not checked, or a value in the text-field
;;; - number-field: text-field with up/down arrows to modify the number
;;; - use a prop image (filename) for button labels, check-box labels, etc.

;; parent: container-area<%>
;; field-props: (list-of (field-id . property<%>))
;; -> (list-of pwig:field-id%)
(define/provide (field-id-properties->widgets parent field-props)
  (dict-map field-props
            (λ(field-id field-id-prop)
              (and (not (send field-id-prop get-hidden))
                   (make-property-widget parent field-id-prop)))
            ))

;; Takes a property<%> and returns a property-widget<%>
;; that is synchronized with the property<%>
;; (pwig is property-widget)
;; A hash-table would be better!
(define (make-property-widget parent prop)
  (let ([pwig
         (let* ([val (send prop get-value)]
                [common%% (λ(c%)(class c% 
                                  (super-new [parent parent]
                                             [prop prop])))]
                [pwig-text (λ(val->text text->val)
                             (new (common%% pwig:text-field%)
                                  [val->text val->text]
                                  [text->val text->val]))]
                )
           (cond [(is-a? prop prop:atom%)
                  (cond [(boolean? val) (new (common%% pwig:check-box%))]
                        [(string? val) (pwig-text (λ(x)x) (λ(x)x))]
                        [(symbol? val) (pwig-text symbol->string string->symbol)]
                        [(number? val) (pwig-text number->string (λ(x)(or (string->number x) 0)))]
                        [(list? val)   (new (common%% pwig:list%))]
                        ;[else (new (common%% pwig:text-field%))]
                        )]
                 [(is-a? prop prop:boolean%)  (new (common%% pwig:check-box%))]
                 [(is-a? prop prop:file%)     (new (common%% pwig:file%))]
                 [(is-a? prop prop:field-id%) (new (common%% pwig:field-id%))]
                 [(is-a? prop prop:one-of%)   (new (common%% pwig:one-of%))] 
                 [(is-a? prop prop:some-of%)  (new (common%% pwig:some-of%))] 
                 ; hgroup before group because inheritance
                 [(is-a? prop prop:hgroup%)   (new (common%% pwig:hgroup%))] 
                 [(is-a? prop prop:group%)    (new (common%% pwig:vgroup%))] 
                 [(is-a? prop prop:popup%)    (new (common%% pwig:popup%))] 
                 [(is-a? prop prop:code%)     (new (common%% pwig:code%))] 
                 ; font% before proc% because child classes are subsumed!
                 [(is-a? prop prop:font%)     (new (common%% pwig:font%))] 
                 [(is-a? prop prop:proc%)     (new (common%% pwig:proc%))] 
                 [else (printf "make-property-widget: Don't know what to do with ~a\n" 
                               prop)
                       #f])
           ; We could really use a `class-case' form...
           )])
    (when (is-a? pwig property-widget<%>)
      (send pwig update))
    ; return value:
    pwig
    ))

(define/provide property-widget<%>
  (interface ()))

(define/provide (property-widget%% c%)
  (class* c% (property-widget<%>)
    (init-field prop)
    (super-new [vert-margin 0])
    
    ; install callback for when the prop is modified
    (send prop set-update-callback
          (λ(prop)(send this update prop)))
    
    ; called when the property% is updated
    (define/public (update [prop prop]) #f) ; to be overriden
    
    ; called when the Update button is pressed
    ; Commits the values of the widgets to the properties
    (define/public (commit) ; to be overriden
      (debug-printf "property widget default commit\n")
      (void)
      )
    ))
      

;; Takes a prop:field-id% as defined in plugins
(define pwig:field-id%
  (class (property-widget%% horizontal-panel%)
    (inherit-field prop)
    (super-new [alignment '(center top)])
;               [vert-margin 2])
    ; The check-box should be bound to another property<%>
    ; that describes the fact that the field-id will be an option
    ; in the generated function code
    (define cb
      (new (tooltip%% check-box%) [parent this]
           [tooltip-text "Is this field a keyword optional argument of the initialization function in the generated code?"]
           [label ""];(to-string field-id)]
           [value (send prop get-option)]
           ;[enabled (not (send prop get-no-code))]
           [vert-margin 2];0]
           [horiz-margin 2];0
           [min-width 0];120]
           [min-height 0]
           [stretchable-width #f]
           [stretchable-height #f]
           ;[callback (λ (cb e) (send prop set-option (send cb get-value)))]
           ))
    (new text-field% [parent this]
         [label ""]
         [horiz-margin 0]
         [vert-margin 0]
         [min-width 120]
         [enabled #f]
         [stretchable-width #f]
         [init-value (to-string (send prop get-field-id))])
          
    ; Add the widget for the contained property<%> :
    (define prop-widget
      (make-property-widget this (send prop get-prop)))
    
    (define/override (commit)
      (send prop set-option (send cb get-value))
      (send prop-widget commit)
      )
    
    ; no need to update ?
    ; because no callback
    ))


(define pwig:check-box%
  (class (property-widget%% check-box%)
    (inherit-field prop)
    (super-new [label ""]
               [stretchable-width #t]
               [stretchable-height #t]
               [horiz-margin 2]
               ;[callback (λ(cb e)(send prop set-value
               ;                        (send this get-value)))]
               )
    (send this  set-label 
          (if (field-bound? label prop)
              (get-field label prop) ; for prop:boolean% objects
              ""))
    
    (define/override (update [prop prop])
      (send this set-value (send prop get-value)))

    (define/override (commit)
      (send prop set-value (send this get-value)))
    ))

(define pwig:text-field%
  (class (property-widget%% text-field%)
    (inherit-field prop)
    (init-field text->val val->text)
    (super-new [label ""]
               [horiz-margin 0]
               [stretchable-width #t]
               ;[callback (λ(cb e)(send prop set-value
               ;                        (text->val (send this get-value))))]
               )
    
    (define/override (update [prop prop])
      (send this set-value (val->text (send prop get-value))))

    (define/override (commit)
      (send prop set-value (text->val (send this get-value))))
    
    ))

(define pwig:file%
  (class (property-widget%% file-button%)
    (inherit-field prop)
    
    (define mid (current-property-mred-id)) ; catch it now, at init time, because at exec time it may not be avaliable!
    
    (define (get-project-dir)
      (send mid get-project-dir))

    (super-new [label "Choose Image..."]
               [stretchable-width #t]
               [directory (get-project-dir)]
               ;[callback (λ(file)(send prop set-value (->string file)))]
               )
    
    (define/override (update [prop prop])
      (send this set-value (send prop get-value)))

    (define/override (commit)
      (let ([f (send this get-value)]
            [base-dir (get-project-dir)])
        (send prop set-value ;(->string 
                              (if (and base-dir f (complete-path? f))
                                  (relative-path base-dir f)
                                  f))));)
    
    ; PROBLEM:
    ; ok for generated code, but not ok for preview project
    ; UNLESS: parameterize current dir to current project when creating the widgets!
    ; or try to use (path->complete-path path [base])
    ))

(define pwig:one-of%
  (class (property-widget%% choice%)
    (inherit-field prop)
    (super-new [label""]
               [stretchable-width #t]
               [choices '()]
               ;[callback (λ(cb e)(send prop set-value
               ;                        (list-ref (send prop get-prop-choices) 
               ;                                  (send this get-selection))))]
               )
    
    (for-each (λ(p)(send this append (to-string p)))
              (send prop get-prop-choices))
     
    (define/override (update [prop prop])
      (send this set-string-selection 
            (to-string (send prop get-value))))

    (define/override (commit)
      (send prop set-value
            (list-ref (send prop get-prop-choices) 
                      (send this get-selection))))
    ))

; Every property-field% takes a corresponding property%
; and only displays it and handles the modification of the values
(define pwig:some-of%
  (class (property-widget%% vertical-panel%)
    (inherit-field prop)
    (super-new [alignment '(left top)]
               [stretchable-width #t])
    
    (define gbox (new group-box-panel% [parent this]
                      [label ""]
                      [alignment '(left top)]
                      [stretchable-width #t]
                      [vert-margin 0]
                      [horiz-margin 2]))
    
    (define check-boxes 
      (let ([vals (send prop get-value)]
            [choices (send prop get-choices)])
        (map (λ(c)(new check-box% [label (to-string c)]
                       [parent gbox]
                       [value (member c vals)]
                       ;[callback (λ(cb e)
                       ;            (send prop set-value
                       ;                  (append-map 
                       ;                   (λ(cb c)(if (send cb get-value)
                       ;                               (list c)
                       ;                               '()))
                       ;                   check-boxes
                       ;                   choices)))]
                       ))
             choices)))

    (define/override (update [prop prop])
      (let ([vals (send prop get-value)])
        (for-each (λ(v cb)(send cb set-value 
                                (if (member v vals) #t #f)))
                  (send prop get-choices)
                  check-boxes)))

    (define/override (commit)
      (let ([choices (send prop get-choices)])
        (send prop set-value
              (append-map 
               (λ(cb c)(if (send cb get-value)
                           (list c)
                           '()))
               check-boxes
               choices))))
    ))

(define (pwig:group%% p%)
  (class (property-widget%% p%)
    (inherit-field prop)
    (super-new [stretchable-width #t]
               [alignment '(left top)])

    (field [widgets
            (map (λ(p)(make-property-widget this p))
                 (send prop get-props))])
    
    ; no need to update ?
    ; because no callback

    (define/override (commit)
      (for-each (λ(w)(send w commit)) widgets))
    
    ))
(define pwig:vgroup% (pwig:group%% vertical-panel%))
(define pwig:hgroup% (pwig:group%% horizontal-panel%))
    
(define pwig:popup%
  (class (property-widget%% button%)
    (inherit-field prop)
    (super-new 
     [label " ... "]
     [stretchable-width #t]
     [callback (λ(b e)
                 (let-values ([(h) (send this get-height)]
                              [(w) (send this get-width)]
                              [(x y) (send this client->screen 
                                           (send this get-x)
                                           (send this get-y))
                                           ])
                   (send dial move (- x w) y)
                   (send dial show #t)))]
     )
        
    (define dial (new dialog% [label ""]
                      [parent (send this get-top-level-window)]
                      ;[style '(no-caption)]
                      [min-width (send this get-width)]
                      ))
    (field [sub-widget (make-property-widget dial (send prop get-prop))])
    (new button% [parent dial]
         [label "Ok"]
         [style '(border)]
         [callback (λ(b e)(send dial show #f)
                     ;.... update values ?
                     )])

    (define/override (commit)
      (send sub-widget commit))
      
    ))

(define pwig:list%
  (class (property-widget%% button%)
    (inherit-field prop)
    
    (super-new
     [label " ... "]
     [stretchable-width #t]
     [callback (λ _
                 (send edit-list show #t)
                 ;(let ([vals (send edit-list get-choices)])
                 ;  ;(printf "returned values: ~a" vals)
                 ;  (when vals
                 ;    (send prop set-value vals)
                 ;    ))
                 )]
     )
    
    (define edit-list 
      (new property-edit-list% [parent (send this get-top-level-window)]
           [label "Edit List values"]
           [empty-allowed? #f]
           ))
    

    (define/override (update [prop prop])
      (let ([vals (send prop get-value)])
        (send edit-list set-choices (send prop get-value)))
      (void))
        
    (define/override (commit)
      (let ([vals (send edit-list get-choices)])
        ;(printf "returned values: ~a" vals)
        (when vals
          (send prop set-value vals)
          )))
    ))

(define pwig:code%
  (class (property-widget%% pane%)
    (super-new [stretchable-width #t])
    ))

(define pwig:proc%
  (class (property-widget%% panel%)
    (inherit-field prop)
    (super-new [stretchable-width #t])

    (field [sub-widget 
            (make-property-widget this (send prop get-prop))])

    (define/override (commit)
      (send sub-widget commit))
    ))
        
(define pwig:font%
  (class (property-widget%% button%)
    (inherit-field prop)
    (super-new [stretchable-width #t]
               [label " Choose Font..."]
               [callback (λ _ 
                           (let* ([ft the-font] ; we get a font% !
                                  [new-ft (get-font-from-user #f #f ft)])
                             ; we set a list:
                             (when new-ft
                               (set! the-font new-ft))))]
                             ;(send (send prop get-prop) set-value
                             ;      (font->list (or new-ft ft)))))]
                )
    (field [the-font (send prop get-value)])

    (define/override (commit)
      ; we set a list:
      (send (send prop get-prop) set-value
            (font->list the-font)))
    ))


#| TESTS | #

(define f (new frame% [label ""]))
(define prop (flat-prop->prop 
              ;(prop:bool "test" #f)
              ;(font-values)
              ;(list "a" "b" "x")
              (new prop:file% [value #f])
              ))
(define field-prop (new prop:field-id% 
                        [field-id 'plop]
                        [value prop]))
(define pwig (make-property-widget f field-prop))
(send f show #t)
; tester aussi generate-code !

;|#