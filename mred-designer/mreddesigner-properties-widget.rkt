#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - properties-widget.rkt                                          #
;; # http://mreddesigner.lozi.org                                                   #
;; # Copyright (C) Lozi Jean-Pierre, 2004 - mailto:jean-pierre@lozi.org             #
;; # Copyright (C) Peter Ivanyi, 2007                                               #
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


;(module mreddesigner-properties-widget mzscheme
;  (require (lib "class.rkt")  
;           (lib "mred.rkt" "mred")
;           (file "mreddesigner-misc.rkt")
;  )
(require "mreddesigner-misc.rkt"
         racket/gui/base)

; ------------------------------------------------------------------------------
; Single value option
; ------------------------------------------------------------------------------

; define a new object for property window
; single value field
; public interfaces:
; - is-editable? , set-editable? , set-name , get-name, set-value , get-value
(define property-value%
  (class horizontal-panel%
    (init-field
      (name   #f)
      (value #f)
      (callback #f)
      (name-width #f)
      (editable? #t)
    )
    
    ; variable to store the current value
    ; we need this storage so when the user leaves this widget without
    ; pressing ENTER then we restore the value to this stored value
    (define current #f)
    
    ; variables to store the internal widgets
    (define name-editor #f)
    (define name-canvas #f)
    (define value-editor #f)
    (define value-canvas #f)
    
    (define blue  (make-object color% 10 36 106))
    (define white (make-object color% 255 255 255))
    (define grey  (make-object color% 200 200 200))
    (define black (make-object color% 0 0 0))
    
    (define delta-normal   (make-object style-delta%))
    (define delta-select   (make-object style-delta%))
    (define delta-inactive (make-object style-delta%))
    
    (public is-editable?)
    (define (is-editable?)
      editable?
    )
    
    (public set-editable?)
    (define (set-editable? bool)
      (set! editable? bool)
      (if bool
        (begin
          (send value-editor hide-caret #f)
          (send value-editor change-style delta-normal 0 'end)
        )
        (begin
          (send value-editor hide-caret #t)
          (send value-editor change-style delta-inactive 0 'end)
        )
      )
    )
    
    (public set-name)
    (define (set-name name)
      (send name-editor erase)
      (send name-editor insert name 0 'same #t)
    )
    
    (public get-name)
    (define (get-name)
      (send name-editor get-text 0 'eof #f #f)
    )
    
    (public set-value)
    (define (set-value val)
      (send value-editor erase)
      (send value-editor insert val 0 'same #t)
      (when (not editable?)
        (send value-editor change-style delta-inactive 0 'end)
      )
    )
    
    (public get-value)
    (define (get-value)
      (send value-editor get-text 0 'eof #f #f)
    )
    
    ; this function changes the style when the field is focused and
    ; restores the default style after unfocus
    (define (property-focus on?)
      (if on?
        (begin
          (send (send name-canvas get-editor) change-style delta-select 0 'end)
          (send name-canvas set-canvas-background blue)
          ; store the current value
          (set! current (get-value))
        )
        (let
          ((val (get-value)))
          ; check whether it is an already accepted value (by ENTER)
          (when (and current (not (equal? val current)))
            (set-value current)
          )
          (set! current #f)
          (send (send name-canvas get-editor) change-style delta-normal 0 'end)
          (send name-canvas set-canvas-background white)
        )
      )
    )
    
    (public unfocus)
    (define (unfocus)
      (set! current #f)
    )
    
    ; subclass the editor so 
    ; - we can handle ENTER and call a function
    ; - we can handle focus and unfocus
    ; - we can handle double clicking
    (define property-editor%
      (class editor-canvas%
        
        ; handle ENTER
        (define/override (on-char event)
          (case (send event get-key-code)
            ((#\return)
             (let ((ok? #t))
               ; if ENTER is pressed and there is a function call it
              (when (and callback (procedure? callback))
                 (callback (get-value))
               )
               (when ok?
                 (set! current (get-value))
               )
             )
             ; we swallow this key
            )
            (else
             (super on-char event)
            )
          )
        )
        
        ; signal focus by making the name field blue
        (define/override (on-focus on?)
          (property-focus on?)
          (super on-focus on?)
        )
        (super-new)
        
        ; double clicking
        (let*
          ((editor (send this get-editor))
           (keymap (send editor get-keymap)))
          (send keymap add-function "all-text-select"
            (lambda (edit event) (send edit select-all)))
          (send keymap map-function "leftbuttondouble" "all-text-select")
        )
      )
    )
    
    ; this function initializes the object
    (define (init)
      ; style deltas for normal name or selected name
      (send delta-normal set-delta-foreground "black")
      (send delta-select set-delta-foreground "white")
      (send delta-inactive set-delta-foreground grey)
      
      ; editors for name and value
      (set! name-editor  (new text%))
      (set! value-editor (new text%))
      
      ; widgets to display
      (set! name-canvas (new editor-canvas%
                             (parent this)
                             (editor name-editor)
                             (style '(no-border no-hscroll no-vscroll))
                             (line-count 1)
                             (stretchable-height #f)
                             (vert-margin 1)
                             (horiz-margin 1)
                             (vertical-inset 0)
                             (horizontal-inset 0)
                             (enabled #f)
                             (min-width name-width)
                             (stretchable-width #f)
                       ))
      (set! value-canvas (new property-editor%
                              (parent this)
                              (editor value-editor)
                              (style '(no-border no-hscroll no-vscroll))
                              (line-count 1)
                              (stretchable-height #f)
                              (vert-margin 1)
                              (horiz-margin 1)
                              (vertical-inset 0)
                              (horizontal-inset 0)
                       ))
      
      ; set the name and the value
      (set-name  name)
      (set-value value)
      ; set the editable state
      (set-editable? editable?)
      ; to ensure that this widget has always a single line
      (send this stretchable-height #f)
    )
    
    (super-new)
    ;
    (init)
  )
)

; ------------------------------------------------------------------------------
; Choice
; ------------------------------------------------------------------------------

(define property-choice-icon (make-object bitmap% (build-path "images" "down.png") 'png #f))

; define a new object for property window
; field with a selection, 
; the list of choices cannot be changed later with the current interface
;
; public interfaces:
; - set-name , get-name , get-value , set-selection
(define/provide property-choice%
  (class horizontal-panel%
    (init-field
      (name   #f)
      (choices #f)
      (selection 0)
      (callback #f)
      (name-width #f)
    )
    
    (define name-editor #f)
    (define name-canvas #f)
    (define value-editor #f)
    (define value-canvas #f)
    (define button #f)
    
    (define blue  (make-object color% 10 36 106))
    (define white (make-object color% 255 255 255))
    (define black (make-object color% 0 0 0))
    
    (define delta-normal (make-object style-delta%))
    (define delta-select (make-object style-delta%))
    
    ; this is private for this class
    (define (set-value val)
      (send value-editor erase)
      (send value-editor insert val 0 'same #t)
    )
    
    (public get-value)
    (define (get-value)
      (send value-editor get-text 0 'eof #f #f)
    )
    
    (public get-name)
    (define (get-name)
      (send name-editor get-text 0 'eof #f #f)
    )
    
    (public set-name)
    (define (set-name name)
      (send name-editor erase)
      (send name-editor insert name 0 'same #t)
    )
    
    (public set-selection)
    (define (set-selection select)
      (when (<= 0 select (- (length choices) 1))
        (set-value (list-ref choices select))
      )
    )
    
    ; this function changes the style when the field is focused and
    ; restores the default style after unfocus
    (define (property-focus on?)
      (if on?
        (begin
          (send (send name-canvas get-editor) change-style delta-select 0 'end)
          (send name-canvas set-canvas-background blue)
        )
        (begin
          (send (send name-canvas get-editor) change-style delta-normal 0 'end)
          (send name-canvas set-canvas-background white)
        )
      )
    )
        
    (public unfocus)
    (define (unfocus)
      (void)
    )
    
    ; ignore keyboard events
    ; handle focusing, when focused make name field blue
    (define property-editor%
      (class editor-canvas%
        (define/override (on-char event)
          (void)
        )
        (define/override (on-focus on?)
          (property-focus on?)
          (super on-focus on?)
        )
        (super-new)
      )
    )
    
    ; handle focusing, when focused make name field blue
    (define property-button%
      (class button%
        (define/override (on-focus on?)
          (property-focus on?)
          (super on-focus on?)
        )
        (super-new)
      )
    )
    
    ; this function initializes the object
    (define (init)
      (send delta-normal set-delta-foreground "black")
      (send delta-select set-delta-foreground "white")
      
      (set! name-editor  (new text%))
      (set! value-editor (new text%))
      
      (set! name-canvas (new editor-canvas%
                             (parent this)
                             (editor name-editor)
                             (style '(no-border no-hscroll no-vscroll))
                             (line-count 1)
                             (stretchable-height #f)
                             (vert-margin 0)
                             (horiz-margin 1)
                             (vertical-inset 0)
                             (horizontal-inset 0)
                             (enabled #f)
                             (min-width name-width)
                             (stretchable-width #f)
                       ))
      (set! value-canvas (new property-editor%
                              (parent this)
                              (editor value-editor)
                              (style '(no-border no-hscroll no-vscroll))
                              (line-count 1)
                              (stretchable-height #f)
                              (vert-margin 1)
                              (horiz-margin 1)
                              (vertical-inset 0)
                              (horizontal-inset 0)
                              (enabled #t)
                       ))
      ; makes the widget look like a disabled widget
      (send value-editor hide-caret #t)
      
      (letrec
        ((popup (new popup-menu%)))
        (set! button (new property-button% 
                          (label property-choice-icon)
                          (parent this)
                          (vert-margin 0)
                          (horiz-margin 0)
                          (callback 
                           (lambda (but e)
                             (let 
                               ((w (send value-canvas get-width))
                                (h (send value-canvas get-height))
                                (x (send value-canvas get-x))
                                (y (send value-canvas get-y))
                                )
                               (send popup set-min-width (+ (- w 5) (send button get-width)))
                               (send value-canvas 
                                     popup-menu popup 
                                     0
                                     (+ y (- h 1)))
                             )
                           )
                         )
                     )
        )
        ; list of menu items
        (for-each
          (lambda (x)
            (new menu-item% 
                 (parent popup)
                 (label x)
;                 (label (to-string x))
                 (callback (lambda (m e)
                             (set-value x)
                             (when (and callback (procedure? callback))
                               (callback x)
                             )
                           )))
          )
          choices
        )
      )
      (set-name  name)
      (set-selection selection)
      (send this stretchable-height #f)
    )
    
    (super-new)
    ;
    (init)
  )
)

; ------------------------------------------------------------------------------
; Option list
; ------------------------------------------------------------------------------

; public interfaces:
; - empty-allowed-get , empty-allowed-set , get-choices , set-choices
(define/provide property-edit-list%
  (class dialog%
    
    (init-field
      (empty-allowed? #f)
    )
    
    ; determines whether the Cancel or the OK button has been pressed
    (define cancel? #f)
    ; list box widget
    (define list-box-data #f)
    
    (public empty-allowed-get)
    (define (empty-allowed-get)
      empty-allowed?
    )
    
    (public empty-allowed-set)
    (define (empty-allowed-set bool)
      (set! empty-allowed? bool)
    )
    
    (public get-choices)
    (define (get-choices)
      (define (get-choices-aux i n)
        (cond
          ((= i n) '())
          (else
           (cons (send list-box-data get-string i)
                 (get-choices-aux (add1 i) n)))))
      (if (not cancel?)
        (get-choices-aux 0 (send list-box-data get-number))
        #f
      )
    )
    
    (public set-choices)
    (define (set-choices lst)
      (for-each
        (lambda (x)
          (when (not (string? x))
            (error "invalid choice for property-edit%: " x)
          )
        )
        lst
      )
      ; FIXME: clear here the text field
      (send list-box-data set lst)
    )
    
    (define (init)
      (letrec 
        ((horizontal-panel-data (new horizontal-panel%
                                     (parent this)
                                     (style '(border))
                                     ))
         (list-box-panel (new horizontal-panel% (parent horizontal-panel-data)))
         (vertical-panel-modify (new vertical-panel%
                                     (parent horizontal-panel-data)
                                     (alignment '(left top))
                                     (stretchable-width #f)))
         (message (new message% 
                       (label "Value")
                       (parent vertical-panel-modify)))
         (text-field-data (new text-field%
                               (parent vertical-panel-modify)
                               (min-width 100)
                               (init-value "")
                               (style '(single))
                               (label #f)
                               (stretchable-height #f)))
         (horizontal-panel-add (new horizontal-panel% 
                                    (parent vertical-panel-modify)))

         (button-add (new button%
                          (parent horizontal-panel-add)
                          (label "Add")
                          (stretchable-width #t)
                          (stretchable-height #f)
                          (min-width 50)
                          (callback 
                            (lambda (b e)
                              (let 
                                ((text (send text-field-data get-value))
                                 (idx  (send list-box-data get-selection))
                                )
                                ; if something is selected, unselect it
                                (when idx
                                  (send list-box-data select idx #f)
                                )
                                ; if something is typed in append to the list
                                (when (> (string-length text) 0)
                                  (send list-box-data append text)))))))
         (button-edit (new button%
                           (parent horizontal-panel-add)
                           (label "Edit")
                           (stretchable-width #t)
                           (stretchable-height #f)
                           (min-width 50)
                           (callback 
                            (lambda (b e)
                              (let 
                                ((text (send text-field-data get-value))
                                 (idx  (send list-box-data get-selection))
                                )
                                ; if something is selected and there is a typed text
                                (when (and idx (> (string-length text) 0))
                                    (send list-box-data set-string idx text)))))))
         (horizontal-panel-move (new horizontal-panel% 
                                     (parent vertical-panel-modify)))
         (button-up     (new button%
                             (parent horizontal-panel-move)
                             (label "Up")
                             (stretchable-width #t)
                             (stretchable-height #f)
                             (min-width 50)
                             (vert-margin 0)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((idx  (send list-box-data get-selection)))
                                  ; if there is a selection and it is not the first element
                                  (when (and idx (> idx 0))
                                    (let
                                      ((prev (send list-box-data get-string (- idx 1)))
                                       (curr (send list-box-data get-string idx))
                                      )
                                      (send list-box-data set-string idx prev)
                                      (send list-box-data set-string (- idx 1) curr)
                                      (send list-box-data set-selection (- idx 1))
                                      )))))))
         (button-down   (new button%
                             (parent horizontal-panel-move)
                             (label "Down")
                             (stretchable-width #t)
                             (stretchable-height #f)
                             (min-width 50)
                             (vert-margin 0)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((idx  (send list-box-data get-selection))
                                   (n    (send list-box-data get-number))
                                  )
                                  ; if there is a selection and it is not the last element
                                  (when (and idx (< idx (- n 1)))
                                    (let
                                      ((next (send list-box-data get-string (+ idx 1)))
                                       (curr (send list-box-data get-string idx))
                                      )
                                      (send list-box-data set-string idx next)
                                      (send list-box-data set-string (+ idx 1) curr)
                                      (send list-box-data set-selection (+ idx 1))
                                      )))))))
         (button-delete (new button%
                             (parent vertical-panel-modify)
                             (stretchable-width #t)
                             (label "Delete")
                             (stretchable-height #f)
                             (callback 
                              (lambda (b e)
                                (let 
                                  ((text (send text-field-data get-value))
                                   (idx  (send list-box-data get-selection))
                                   (n    (send list-box-data get-number))
                                  )
                                  ; if there is a selection and
                                  ;   empty list is allowed or
                                  ;   empty list is not allowed and there are more than 1 element
                                  (when (and idx
                                           (or empty-allowed?
                                               (and (not empty-allowed?)
                                                    (> n 1))))
                                    (send text-field-data set-value "")
                                    (send list-box-data select idx #f)
                                    (send list-box-data delete idx)))))))
         (horizontal-panel-buttons (new horizontal-panel%
                                        (parent this)
                                        (alignment '(center center))
                                        (vert-margin 2)
                                        (stretchable-height #f)
                                        (stretchable-width #t)))
         (button-ok (new button%
                         (parent horizontal-panel-buttons)
                         (min-width 70)
                         (label "OK")
                         (stretchable-width #f)
                         (stretchable-height #f)
                         (callback
                           (lambda (b e)
                             ; Ok was pressed, clear text field and hide window
                             (set! cancel? #f)
                             (send text-field-data set-value "")
                             (send this show #f)))))
         (button-cancel (new button%
                             (parent horizontal-panel-buttons)
                             (stretchable-width #f)
                             (min-width 70)
                             (label "Cancel")
                             (stretchable-height #f)
                             (callback
                               (lambda (b e)
                                 ; Cancel was pressed, clear text field and hide window
                                 (set! cancel? #t)
                                 (send text-field-data set-value "")
                                 (send this show #f)))))
        )
        (set! list-box-data (new list-box%
                                 (parent list-box-panel)
                                 (choices '())
                                 (selection #f)
                                 (style '(single vertical-label))
                                 (label "List of choices")
                                 (callback
                                   (lambda (l e)
                                     (let*
                                       ((idx (send l get-selection)))
                                       ; if there is a selection set the text in the edit box
                                       (when idx
                                         (send text-field-data 
                                               set-value 
                                               (send l get-string idx))))))))
        ; double clicking for the text field
        (let*
          ((editor (send text-field-data get-editor))
           (keymap (send editor get-keymap)))
          (send keymap add-function "all-text-select"
            (lambda (edit event) (send edit select-all)))
          (send keymap map-function "leftbuttondouble" "all-text-select")
        )
      )
    )
    
    (super-new (style '(no-caption))
               (width 300)
               (height 150)
               (border 4)
    )
    ;
    (init)
  )
)

(define property-option-icon (make-object bitmap% (build-path "images" "dots.png") 'png #f))

; define a new object for property window
; field with modifiable selection
(define property-option-list%
  (class horizontal-panel%
    (init-field
      (name   #f)
      (choices #f)
      (selection 0)
      (callback #f)
      (width #f)
      (empty-allowed? #f)
    )
    
    (define name-editor #f)
    (define name-canvas #f)
    (define value-editor #f)
    (define value-canvas #f)
    (define button #f)
    (define popup #f)
    
    (define blue  (make-object color% 10 36 106))
    (define white (make-object color% 255 255 255))
    (define black (make-object color% 0 0 0))
    
    (define delta-normal (make-object style-delta%))
    (define delta-select (make-object style-delta%))
    
    (public empty-allowed-get)
    (define (empty-allowed-get)
      (let ((allowed? (send popup empty-allowed-get)))
        (set! empty-allowed? allowed?)
        allowed?
      )
    )
    
    (public empty-allowed-set)
    (define (empty-allowed-set bool)
      (set! empty-allowed? bool)
      (send popup empty-allowed-set bool)
    )
    
    (public get-name)
    (define (get-name)
      (send name-editor get-text 0 'eof #f #f)
    )
    
    (public set-name)
    (define (set-name name)
      (send name-editor erase)
      (send name-editor insert name 0 'same #t)
    )
    
    (public set-choices)
    (define (set-choices lst)
      (set! choices lst)
      (send popup set-choices lst)
    )
    
    ; this function changes the style when the field is focused and
    ; restores the default style after unfocus
    (define (property-focus on?)
      (if on?
        (begin
          (send (send name-canvas get-editor) change-style delta-select 0 'end)
          (send name-canvas set-canvas-background blue)
        )
        (begin
          (send (send name-canvas get-editor) change-style delta-normal 0 'end)
          (send name-canvas set-canvas-background white)
        )
      )
    )
        
    (public unfocus)
    (define (unfocus)
      (void)
    )

    ; ignore keyboard events
    ; handle focusing, when focused make name field blue
    (define property-editor%
      (class editor-canvas%
        (define/override (on-char event)
          (void)
        )
        (define/override (on-focus on?)
          (property-focus on?)
          (super on-focus on?)
        )
        (super-new)
      )
    )
    
    ; handle focusing, when focused make name field blue
    (define property-button%
      (class button%
        (define/override (on-focus on?)
          (property-focus on?)
          (super on-focus on?)
        )
        (super-new)
      )
    )
    
    ; this function initializes the object
    (define (init)
      (send delta-normal set-delta-foreground "black")
      (send delta-select set-delta-foreground "white")
      
      (set! name-editor  (new text%))
      (set! value-editor (new text%))
      
      (set! name-canvas (new editor-canvas%
                             (parent this)
                             (editor name-editor)
                             (style '(no-border no-hscroll no-vscroll))
                             (line-count 1)
                             (stretchable-height #f)
                             (vert-margin 0)
                             (horiz-margin 1)
                             (vertical-inset 0)
                             (horizontal-inset 0)
                             (enabled #f)
                             (min-width width)
                             (stretchable-width #f)
                       ))
      (set! value-canvas (new property-editor%
                              (parent this)
                              (editor value-editor)
                              (style '(no-border no-hscroll no-vscroll))
                              (line-count 1)
                              (stretchable-height #f)
                              (vert-margin 1)
                              (horiz-margin 1)
                              (vertical-inset 0)
                              (horizontal-inset 0)
                              (enabled #t)
                       ))
      (send value-editor hide-caret #t)
      (set! popup (new property-edit-list% 
                       (label "Choices")
                       (parent #f)
                       (empty-allowed? empty-allowed?)
                       ))
      (set! button (new property-button% 
                        (label property-option-icon)
                        (parent this)
                        (vert-margin 0)
                        (horiz-margin 0)
                        (callback 
                         (lambda (but e)
                           (let*
                             ((h (send name-canvas get-height))
                              (x (send name-canvas get-x))
                              (y (send name-canvas get-y))
                              )
                             (let-values
                               (((xx yy) (send name-canvas client->screen (- x 1) (+ y h))))
                               ; position the popup window under the current widget
                               (send popup move xx yy)
                               (send popup set-choices choices)
                               ; show the dialog window
                               (send popup show #t)
                               ; after the dialog window has been closed
                               (let
                                 ((lst (send popup get-choices)))
                                 (when lst
                                   (set! choices (send popup get-choices))
                                   (when (and callback (procedure? callback))
                                     (callback choices))))))))))
      (set-name  name)
      (send this stretchable-height #f)
    )
    
    (super-new)
    ;
    (init)
  )
)

; ------------------------------------------------------------------------------
; Property panel
; ------------------------------------------------------------------------------

(provide property-panel%)
(define property-panel%
  (class vertical-panel%
    (init-field
      (callback #f)
    )
    (unless (or (not callback) 
                (procedure-arity-includes? callback 2))
      (raise-type-error 'property-panel%
                        "procedure of arity 1"
                        callback)
    )
    
    (define widget-table #f)
    (define widget-empty #f)
    (define widget-necessary #f)
    (define widget-optional #f)
    
    (public empty)
    (define (empty)
      (send this import #f #f '())
    )
    
    (define horiz-alignment-options '("left" "center" "right"))
    (define vert-alignment-options  '("top" "center" "bottom"))
    (define boolean-true "true")
    (define boolean-false "false")
    (define boolean-options (list boolean-true boolean-false))
    (define single-option "single")
    (define multiple-option "multiple")
    (define extended-option "extended")
    (define selection-options (list single-option multiple-option extended-option))
    (define text-field-options (list single-option multiple-option))
    (define horizontal-option "horizontal")
    (define vertical-option "vertical")
    (define direction-options (list horizontal-option vertical-option))
    (define horizontal-label-option "horizontal-label")
    (define vertical-label-option "vertical-label")
    (define label-direction-options (list horizontal-label-option vertical-label-option))
    
    
    
    (define (bool-choice-value w name val)
      (cond
        ((member name '(enabled value stretchable-width stretchable-height))
         (if val
           (send w
                 set-selection
                 (- (length boolean-options)
                    (length (member boolean-true boolean-options))))
           (send w
                 set-selection
                 (- (length boolean-options)
                    (length (member boolean-false boolean-options))))
         )
        )
      )
    )
    
    (define (style-options type value-list)
      (letrec
        ((true  (- (length boolean-options)
                   (length (member boolean-true boolean-options))))
         (false (- (length boolean-options)
                   (length (member boolean-false boolean-options))))
         (w-lst '())
         ; function for boolean type
         (widget-bool-set 
          (lambda (type prop)
            (let
              ((w (hash-ref widget-table type #f)))
              (if (member prop value-list)
                (send w set-selection true)
                (send w set-selection false)
              )
              (set! w-lst (cons w w-lst))
            )
          )
         )
         ; function for boolean type, 
         ; but the actual style parameter is reversed
         ; for example the question was "border?" but it sets "no-border" property
         (widget-bool-set-not
          (lambda (type prop)
            (let
              ((w (hash-ref widget-table type #f)))
              (if (member prop value-list)
                (send w set-selection false)
                (send w set-selection true)
              )
              (set! w-lst (cons w w-lst))
            )
          )
         )
        )
        ; deleted
        (when (member type '(button radio-box check-box
                           panel horizontal-panel vertical-panel
                           tab-panel group-box-panel
                           message slider gauge list-box
                           choice text-field canvas))
          (widget-bool-set 'style-deleted 'deleted)
        )
        ; border and no-border
        (when (member type '(button panel horizontal-panel vertical-panel
                           tab-panel ; actually this has 'no-border' style
                           canvas))
          (if (equal? type 'tab-panel)
            (widget-bool-set-not 'style-border 'no-border)
            (widget-bool-set 'style-border 'border)
          )
        )
        ; style for frames
        (when (equal? type 'frame)
          (begin
            (widget-bool-set-not 'style-no-resize-border 'no-resize-border)
            (widget-bool-set-not 'style-no-caption 'no-caption)
            (widget-bool-set-not 'style-no-system-menu 'no-system-menu)
            (widget-bool-set     'style-toolbar-button 'toolbar-button)
            (widget-bool-set     'style-hide-menu-bar 'hide-menu-bar)
            (widget-bool-set     'style-float 'float)
            (widget-bool-set     'style-metal 'metal)
          )
        )
        ; horizontal or vertical direction
        (when (member type '(radio-box slider gauge))
          (let
            ((w (hash-ref widget-table 'style-direction #f)))
            (cond 
              ((member 'horizontal value-list)
               (send w set-selection (- (length direction-options)
                                        (length (member horizontal-option direction-options)))))
              ((member 'vertical value-list)
               (send w set-selection (- (length direction-options)
                                        (length (member vertical-option direction-options)))))
            )
            (set! w-lst (cons w w-lst))
          )
        )
        ; horizontal or vertical labels
        (when (member type '(radio-box slider gauge list-box choice text-field))
          (let
            ((w (hash-ref widget-table 'style-label-direction #f)))
            (cond 
              ((member 'vertical-label value-list)
               (send w set-selection (- (length label-direction-options)
                                        (length (member vertical-label-option label-direction-options)))))
              (else
               (send w set-selection (- (length label-direction-options)
                                        (length (member horizontal-label-option label-direction-options)))))
            )
            (set! w-lst (cons w w-lst))
          )
        )
        (when (equal? type 'slider)
          (widget-bool-set 'style-plain 'plain)
        )
        (when (member type '(text-field canvas))
          (widget-bool-set 'style-hscroll 'hscroll)
        )
        (when (equal? type 'canvas)
          (begin
            (widget-bool-set 'style-vscroll 'vscroll)
            (widget-bool-set 'style-control-border 'control-border)
            (widget-bool-set 'style-resize-corner 'resize-corner)
            (widget-bool-set 'style-gl 'gl)
            (widget-bool-set-not 'style-no-autoclear 'no-autoclear)
            (widget-bool-set 'style-transparent 'transparent)
          )
        )
        (when (equal? type 'text-field)
          (let
            ((w (hash-ref widget-table 'style-text-field #f)))
            (if (member 'single value-list)
              (send w set-selection (- (length text-field-options)
                                       (length (member single-option text-field-options))))
              (send w set-selection (- (length text-field-options)
                                       (length (member multiple-option text-field-options))))
            )
            (widget-bool-set 'style-password 'password)
            
            (set! w-lst (cons w w-lst))
          )
        )
        (when (equal? type 'list-box)
          (let
            ((w (hash-ref widget-table 'style-selection #f)))
            (cond 
              ((member 'single value-list)
               (send w set-selection (- (length selection-options)
                                        (length (member single-option selection-options)))))
              ((member 'multiple value-list)
               (send w set-selection (- (length selection-options)
                                        (length (member multiple-option selection-options)))))
              ((member 'extended value-list)
               (send w set-selection (- (length selection-options)
                                        (length (member extended-option selection-options)))))
            )
            (set! w-lst (cons w w-lst))
          )
        )
        w-lst
      )
    )
    
    ;/****f*
    ;* NAME
    ;*   import
    ;* DESCRIPTION
    ;*   This function imports a property list into the property window
    ;* ARGUMENTS
    ;*   id - the identification string of the item, 
    ;*        this id is also used in the hierarchy widget
    ;*   type - the type of the widget
    ;*   prop-lst - the list of properties as an association list,
    ;*        every element in the list contains a name and a value,
    ;*        but the value can be a list as well. If the value is a list
    ;*        then a property-choice% window is created.
    ;******/
    (public import)
    (define (import id type prop-lst)
        ; DEBUG:
        (printf "import: prop-lst:\n~a\n" prop-lst)
      (if (null? prop-lst)
        (send this change-children (lambda (lst) (list widget-empty)))
        (let
          ((necessary-list '())
           (optional-list '())
           (necessary (assoc 'necessary prop-lst))
           ;(id-w (hash-table-get widget-table 'id #f))
           (id-w (hash-ref widget-table 'id #f))
          )
          ; which ever widget has focus, unfocus it
          (hash-for-each
            widget-table
            (lambda (key w)
              (send w unfocus)
            )
          )
          (if (equal? id "project")
            (send id-w set-editable? #f)
            (send id-w set-editable? #t)
          )
          (when necessary
            (set! necessary (cadr necessary))) ; ???  for id ? (LO)
          (for-each
            (lambda (prop)
              (let* 
                ((type (car prop))
                 (val (cadr prop))
                 (w (hash-ref widget-table type #f))
                 ; list of specially handled properties
                 (except '(selection style alignment choices))
                 (is-except (member type except))
                )
                (when (and w (not is-except))
                  (begin
                    ; single value properties
                    (when (is-a? w property-value%)
                      (send w set-value (to-string val))
                    )
                    ; multiple value properties, with choices
                    (when (is-a? w property-choice%)
                      (bool-choice-value w type val)
                    )
                    ; determine whether it is a necessary or an optional property
                    (if (and necessary (member (car prop) necessary))
                      (set! necessary-list (cons w necessary-list))
                      (set! optional-list  (cons w optional-list))
                    )
                  )
                 ;; else widget not found for type
                  ; (unless is-except
                      ; (begin
                        ; (printf "widget not found for type: ~a~n" type)
                        ; (add-property-widget type "plop" val #t)
                        ; ))
                )
                ; properties that are handled separately
                (cond
                  ; alignment
                  ((equal? (car prop) 'alignment)
                   (let
                     ((horiz-align (symbol->string (caadr prop)))
                      (vert-align  (symbol->string (cadadr prop)))
                      (horiz-w     (hash-ref widget-table 'halignment #f))
                      (vert-w      (hash-ref widget-table 'valignment #f))
                     )
                     (send horiz-w
                           set-selection
                           (- (length horiz-alignment-options)
                              (length (member horiz-align horiz-alignment-options))))
                     (send vert-w
                           set-selection
                           (- (length vert-alignment-options)
                              (length (member vert-align vert-alignment-options))))
                     (set! optional-list (append (list horiz-w vert-w) optional-list))
                   )
                  )
                  ; selection
                  ((equal? (car prop) 'selection)
                   (let
                     ((w (hash-ref widget-table 'selection #f)))
                     (if (cadr prop)
                       (send w set-value (to-string (cadr prop)))
                       (send w set-value "")
                     )
                   )
                   (set! optional-list (cons w optional-list))
                  )
                  ; style
                  ((equal? (car prop) 'style)
                   (set! optional-list (append optional-list (style-options type (cadr prop))))
                  )
                  ; choices
                  ((equal? (car prop) 'choices)
                   (let
                     ((w (hash-ref widget-table 'choices #f)))
                     (send w set-choices (cadr prop))
                   )
                   (set! optional-list (cons w optional-list))
                  )
                )
              )
            )
            prop-lst
          )
          (send id-w set-value id)
          (set! necessary-list (append (list widget-necessary id-w)
                                       (reverse necessary-list)))
          (if (not (null? optional-list))
            (set! optional-list (cons widget-optional (reverse optional-list)))
            (set! optional-list (reverse optional-list))
          )
          (send this show #f)
          (send this 
                change-children 
                (lambda (lst) (append necessary-list optional-list)))
          (send this show #t)
        )
      )
    )
    
    (public set-value)
    (define (set-value prop val)
      (let
        ((w (hash-ref widget-table prop #f)))
        (cond
          ((is-a? w property-value%)
           (send w set-value (to-string val))
          )
          ((is-a? w property-choice%)
           (send w set-selection val)
          )
          (else
            (error (string-append "unhandled setting of property '"
                                  (symbol->string prop) "'"))
          )
        )
      )
    )
    
    (public get-text)
    (define (get-text prop)
      (let
        ((w (hash-ref widget-table prop #f)))
        (if (not (is-a? w property-value%))
          (error (string-append "trying to get wrong property '"
                                (symbol->string prop) "'"))
          (send w get-value)
        )
      )
    )
    
    (define (add-property-widget type text vals edit?)
      (cond
        ((list? vals)
         (hash-set! widget-table
                          type
                          (new property-choice%
                               (parent this)
                               (name text)
                               (choices vals)
                               (selection 0)
                               (callback (lambda (val)
                                           (when callback
                                             (callback type val))))
                               (name-width 140)))
        )
        ((string? vals)
         (hash-set! widget-table
                          type
                          (new property-value%
                               (parent this)
                               (name text)
                               (value vals)
                               (callback (lambda (val)
                                           (when callback
                                             (callback type val))))
                               (name-width 140)
                               (editable? edit?)))
        )
        (else
         (hash-set! widget-table
                          type
                          (new property-option-list%
                               (parent this)
                               (name text)
                               (choices '())
                               (callback (lambda (val)
                                           (when callback
                                             (callback type val))))
                               (width 140)
                               (empty-allowed? edit?)))
        )
      ))
    
    (define (init)
      (set! widget-table (make-hash 'equal))
      (set! widget-empty 
            (new canvas%
                 (parent this) 
                 (min-height 300)
                 (paint-callback 
                   (lambda (c dc)
                     (let*
                       ((w  (send c get-width))
                        (h  (send c get-height))
                        (k-bold-font  (make-object font% 11 'system 'normal 'bold #f 'smoothed #t))
                        (k-gray-brush (make-object brush% (get-panel-background) 'solid))
                        (k-invisible-pen (make-object pen% 
                                                      (make-object color% 0 0 0) 
                                                      0 
                                                      'transparent))
                       )
                       (send dc clear)
                       (send dc set-pen k-invisible-pen)
                       (send dc set-brush k-gray-brush)
                       (send dc draw-rectangle 0 0 w h)
                       (send dc set-font k-bold-font)
                       (send dc 
                             draw-text 
                             "<No selected element>"
                             (- (/ w 2) 70) (- (/ h 2) 10))
                     )))))
                                   
      (letrec
        ()
        (set! widget-necessary (new horizontal-panel% (parent this) (stretchable-height #f)))
        (new message% (label "Necessary")(parent widget-necessary))
        
        (set! widget-optional (new horizontal-panel% (parent this) (stretchable-height #f)))
        (new message% (label "Optional")(parent widget-optional))
        
        (for-each
          (lambda (x)
            (let
              ((type    (list-ref x 0))
               (text    (list-ref x 1))
               (vals    (list-ref x 2))
               (edit?   (list-ref x 3))
              )
              (add-property-widget type text vals edit?)
            )
          )
          (list '(id "id" "" #t)
                '(label "label" "" #t)
                '(width "width" "" #t)
                '(height "height" "" #t)
                '(x "x" "" #t)
                '(y "y" "" #t)
                 (list 'enabled "enabled?" boolean-options #f)
                '(border "border" "" #t)
                '(spacing "spacing" "" #t)
                 (list 'halignment "horizontal alignment" horiz-alignment-options #f)
                 (list 'valignment "vertical alignment" vert-alignment-options #f)
                '(min-width "min width" "" #t)
                '(min-height "min height" "" #t)
                 (list 'stretchable-width "stretchable width?" boolean-options #f)
                 (list 'stretchable-height "stretchable height?" boolean-options #f)
                '(vert-margin "vertical margin" "" #t)
                '(horiz-margin "horizontal margin" "" #t)
                 (list 'value "value?" boolean-options #f)
                '(min-value "min value" "" #t)
                '(max-value "max value" "" #t)
                '(init-value "init value" "" #t)
                '(range "range" "" #t)
                '(selection "selection" "" #t)
                ; style options
                 (list 'style-deleted "deleted?" boolean-options #f)
                 (list 'style-border "border?" boolean-options #f)
                 (list 'style-no-resize-border "resize border?" boolean-options #f)
                 (list 'style-no-caption "caption?" boolean-options #f)
                 (list 'style-no-system-menu "system menu?" boolean-options #f)
                 (list 'style-toolbar-button "toolbar button?" boolean-options #f)
                 (list 'style-hide-menu-bar "hide menu bar?" boolean-options #f)
                 (list 'style-float "float?" boolean-options #f)
                 (list 'style-metal "metal?" boolean-options #f)
                 (list 'style-plain "plain?" boolean-options #f)
                 
                 (list 'style-selection "selection mode?" selection-options #f)
                 (list 'style-text-field "style?" text-field-options #f)
                 (list 'style-direction "direction?" direction-options #f)
                 (list 'style-label-direction "label direction?" label-direction-options #f)
                 
                 (list 'style-hscroll "horizontal scroll?" boolean-options #f)
                 (list 'style-vscroll "vertical scroll?" boolean-options #f)
                 (list 'style-password "password?" boolean-options #f)
                 (list 'style-control-border "control border?" boolean-options #f)
                 (list 'style-resize-corner "resize corner?" boolean-options #f)
                 (list 'style-gl "OpenGL?" boolean-options #f)
                 (list 'style-no-autoclear "autoclear?" boolean-options #f)
                 (list 'style-transparent "transparent?" boolean-options #f)
                 ; choices
                 (list 'choices "choices" #f #f)
           )
        )
      )
    )
    (super-new)
    ;
    (init)
    (send this min-width 300)
;    (send this min-height 300)
  )
)


