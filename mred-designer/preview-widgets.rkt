#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # preview-widgets.rkt                                                            #
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

(require "misc.rkt"
         "properties.rkt"
         )

(define current-mred-id #f)

(define/provide (get-current-mred-id) current-mred-id)

(define/provide (set-current-mred-id mid)
  (debug-printf "set-current-mred-id:~a\n" mid)
  (debug-printf "current widget set:~a\n" (and mid (send mid get-id)))
  (set! current-mred-id mid))

;;; Returns a duplicate of the given widget with all its properties and id.
;(define/provide-mock (duplicate-widget w parent)
;  (make-widget (send w get-plugin) parent (send w get-properties)))

; should be in another file?
(define/provide (select-mred-id mid)
  (debug-printf "select-mred-id: ~a\n" mid)
  (set-current-mred-id mid)
  ;(printf "(select-mred-id ~a)\n" (send mid get-id))
  )

;(define/provide-mock (replace-widget mid)
;  (send mid replace-widget))

;(define/provide (delete-mred-id mred-id)
;  (send mred-id delete))
