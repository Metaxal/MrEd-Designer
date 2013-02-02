#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - help.rkt                                                       #
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

(require net/sendurl
         "mreddesigner-misc.rkt"
         )
  
(define/provide (help-online-help)
  (send-url "https://github.com/Metaxal/MrEd-Designer/wiki")
  #;(send-url "http://mred-designer.origo.ethz.ch/wiki/doc"))

(define/provide (help-mred-help)
  (send-url "http://docs.racket-lang.org/gui/Windowing_Classes.html")
  #;(send-url "http://docs.plt-racket.org/gui/Windowing_Classes.html"))

;; Obfuscate emails a bit:
(define (mail-to user-list domain-list)
  (apply string-append 
         "mailto:"
         (append (add-between user-list ".")
                 (list "@")
                 (add-between domain-list "."))))

;; This function is called when the user chooses "About MrEd Designer..." in the help menu
(provide help-about-dialog)
(define (help-about-dialog)
  ;; Let's build the whole dialog using a let*
  (let*  ((dialog (new dialog% 
                       (label (string-append "About " application-name "..."))
                       (parent #f) 
                       (width 510) 
                       (height 259)))
          ;; The main vertical pane...
          (vertical-pane (new vertical-pane% (parent dialog) (border 5)))
          ;; We call the canvas class...
          (canvas (new canvas% 
                       (parent vertical-pane) 
                       (style '(border)) 
                       (min-width 510) 
                       (min-height 259)
                       (paint-callback
                         (lambda (canvas dc)
                           (let
                             ((k-logo (make-object bitmap% (build-path "images" "about.png") 'png #f))
                              (k-font (make-object font% 11 'system 'normal 'light #f 'smoothed #t))
                             )
                             (send dc draw-bitmap k-logo 0 0 'solid (make-object color% 0 0 0) #f)
                             (send dc set-font k-font)
                             (send dc draw-text (string-append " - Version " application-version) 354 183)
                             (send dc draw-text "(C) Jean-Pierre Lozi, 2004"   41 200)
                             (send dc draw-text "(C) Peter Ivanyi, 2007, 2008" 41 220)
                             (send dc draw-text "(C) Laurent Orseau, 2010"     41 240)
                           )
                         )
                       )
                  )
          )
          ;; A very, very summed up information about the license...
          (message1 (new message% (label "This software is distributed under the terms of the General Public License (GPL),") (parent vertical-pane)))
          (message2 (new message% (label "either version 2 of the license, or (at your option) any later version.") (parent vertical-pane)))
          ;; The buttons' pane...
          (horizontal-pane (new horizontal-panel% (parent vertical-pane) (alignment '(center center))))
          ;; The 3 buttons...
          (button (new button% (label "Contact...") (min-width 166)(parent horizontal-pane)
                       (callback (lambda (button control-event)
                                   (send-url (mail-to
                                              '("laurent" "orseau")
                                              '("gmail" "com"))
                                             )))))
                                   ;(send-url "mailto:pivanyi@freemail.hu")))))
          (button (new button% (label "Website...") (min-width 166)(parent horizontal-pane)
                       (callback (lambda (button control-event)
                                   (send-url "http://mred-designer.origo.ethz.ch")))))
                                   ;(send-url "http://www.hexahedron.hu/personal/peteri/mreddesigner")))))
          (button (new button% (label "Close") (min-width 166)(parent horizontal-pane)
                       (callback (lambda (button control-event)
                                   (send dialog show #f))))))
    ;; The main function body
    (send dialog center)
    (send dialog show #t)))


;) ;end of module

