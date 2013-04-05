#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - tooltip.rkt                                                    #
;; # http://mreddesigner.lozi.org                                                   #
;; # Copyright (C) Lozi Jean-Pierre, 2004 - mailto:jean-pierre@lozi.org             #
;; # Copyright (C) Peter Ivanyi, 2007                                               #
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

;;; This module provides a tooltip%% mixin that can be used on buttons, checkboxes, etc.

(require "mreddesigner-misc.rkt"
         )

; This is the tooltip message which appears in a tooltip window
(define tooltip-label%
  (class canvas% 
    (inherit get-parent get-dc get-client-size 
             min-width min-height
             stretchable-width stretchable-height)
    (override on-paint)
    
    ; initially no text is assigned to the label
    (init-field (text ""))
    
    ; method to change the text of the label
    ; the widget will be resized and push other widgets to the right !!!
    (define/public (set-label-text new-text)
      (unless (equal? text new-text)
        (set! text new-text)  ; set new text
        (update-min-sizes)    ; recalculate the size of the widget and set it
        (on-paint))           ; redraw
      )          
    
    (define/public (get-label-text)
      text
      )
    
    (define label-inset 1)
    (define black-color (make-object color% "BLACK"))
    (define bg-color (make-object color% "WHITE"))
    
    ; the font to use for the text
    (define label-font
      (send the-font-list find-or-create-font
            9 'decorative 'normal 'normal #f))
    
    ; method to draw the text of the widget
    (define (draw-label dc text w h)
      ; background square to draw
      (send dc set-pen (send the-pen-list find-or-create-pen
                             bg-color 1 'solid))
      (send dc set-brush (send the-brush-list find-or-create-brush
                               bg-color 'solid))
      (send dc draw-rectangle 0 0 w h)
      
      ; boundary
      (send dc set-pen (send the-pen-list find-or-create-pen
                             black-color 1 'solid))
      (send dc draw-line 0 0 w 0)
      (send dc draw-line (- w 1) 0 (- w 1) h)
      (send dc draw-line w (- h 1) 0 (- h 1))
      (send dc draw-line 0 h 0 0)
      
      ; draw text into the square
      (when text
        ; set colors, fonts, etc.
        (send dc set-text-foreground black-color)
        (send dc set-text-background bg-color)
        (send dc set-font label-font)
        (send dc draw-text text
              (+ label-inset 1)
              (+ label-inset 1))))
    
    ; calculate the minimum size of the widget containing the text
    (define (calc-min-sizes dc text)
      (send dc set-font label-font)
      (let-values ([(w h a d) (send dc get-text-extent text label-font)])
        (let ([ans-w
               (+ label-inset
                  label-inset
                  1
                  (max 0 (inexact->exact (ceiling w))))]
              [ans-h
               (+ label-inset 
                  label-inset
                  1
                  (max 0 (inexact->exact (ceiling h))))])
          (values ans-w ans-h))))
    
    ; for the current value of text (private field) 
    ; - calculate the minimum size of the widget
    ; - set minimum values in the widget
    ; - notify parent, so it can rearrange widgets
    (define (update-min-sizes)
      (let-values ([(w h) (calc-min-sizes (get-dc) text)])
        (min-width (+ w 2))
        (min-height (+ h 2))
        (send (get-parent) reflow-container)))
    
    ; drawing method for label widget
    (define (on-paint)
      (let ([dc (get-dc)])
        (let-values ([(w h) (get-client-size)])
          (draw-label dc text w h))))
    
    (super-new)
    
    ; size update for initial field declaration
    (update-min-sizes)
    ; widget is not resizeable
    (stretchable-width #f)
    (stretchable-height #f)
    )
  )

(define/provide tooltip<%> (interface () ))
(define/provide tooltip%%
  (mixin (subwindow<%>) (tooltip<%>)
    ; the class must be a subwindow<%>
    ; and it is then a tooltip<%>
    
    (init-field 
     (tooltip-text " ")
     )
    
    (define start-timer #f)
    ; this is the timer to make the tooltip window to disappear
    (define timeout-timer #f)
    ; whether the tooltip window is shown
    (define shown? #f)
    ; the tooltip window
    (define tooltip #f)
    
    (define (tooltip:clear)
      (when start-timer
        (send start-timer stop)
        (set! start-timer #f)
        )
      (when timeout-timer
        (send timeout-timer stop)
        (set! timeout-timer #f)
        )
;;      (when (and tooltip shown?)
      (when tooltip
        (send tooltip show #f)
        (set! tooltip #f)
;;        (set! shown? #f)
        )
      (set! shown? #f) ;; always clear the shown flag
      )
    
    (define (tooltip:setup)
;;      (send start-timer stop)
;;      (set! start-timer #f)
      (tooltip:clear) ;; clear the previous tooltip completely
      (let
          ((x (inexact->exact (round (* (send this get-width) 0.5))))
           (y (+ (send this get-height) 1))
           (text tooltip-text)
           )
        (let-values
            (((sx sy) (send this client->screen x y)))
          (let*
              ((frame (new frame%
                           (parent #f)
                           (label "")
                           (stretchable-height #f)
                           (stretchable-width #f)
                           (x sx)
                           (y sy)
                           (width 46)
                           (height 17)
                           (border 0)
                           (style '(no-system-menu no-caption no-resize-border float))
                           )
                      )
               (message (new tooltip-label% (parent frame) (text text)))
               )
            (set! tooltip frame)
            (set! timeout-timer (new timer% (notify-callback tooltip:clear)
;;                                            (interval        2500)
                                            (interval        4500)
                                            (just-once?      #t)
                                            )
                  )
            (send tooltip show #t)
            (set! shown? #t)
            )
          )
        )
      )
    
    ;; Warning! 
    ;; If this method is overriden in a child class,
    ;; it must be call with (super on-subwindow-event w e) 
    (define/override (on-subwindow-event w e)
      (cond
        ( (equal? (send e get-event-type) 'enter)
          (when (not shown?)
              (set! start-timer (new timer% (notify-callback tooltip:setup)
;;                                     (interval        600)
                                     (interval        1200)
                                     (just-once?      #t)))
              )
          )
        ( (member (send e get-event-type) '(leave))
          (tooltip:clear)
;;          (print "leave")
          )
        ( (member (send e get-event-type) '(left-down left-up))
          (tooltip:clear)
          )
        ;          ( (equal? (send e get-event-type) 'motion)
        ;          )
        )
      
      ;        (display (send e get-event-type))(newline)
      
      ; also call the event of the above class!
      (super on-subwindow-event w e) 
      
      ; this is important, so we pass the event further
      #f
      )
    
    (super-new)
    )
  )

(define/provide tooltip-button%    (tooltip%% button%))
(define/provide tooltip-check-box% (tooltip%% check-box%))
(define/provide tooltip-radio-box% (tooltip%% radio-box%))
(define/provide tooltip-list-box%  (tooltip%% list-box%))

#| TESTS

(define f (new frame% (label "Test")))
(define b (new (tooltip%% button%) (parent f)
               (label "Hello")
               (tooltip-text "Button") ))
(define c (new (tooltip%% check-box%) (parent f)
               (label "Hello")
               (tooltip-text "Check Box") ))
(define r (new (tooltip%% radio-box%) (parent f)
               (label "Hello")
               (choices '("a" "b" "c"))
               (tooltip-text "Radio Box") ))
(send f show #t) 

|#
