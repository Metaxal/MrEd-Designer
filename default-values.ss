#lang scheme

;; ##################################################################################
;; # ============================================================================== #
;; # default-values.ss                                                              #
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

(require scheme/gui/base
         "properties.ss"
         "code-write.ss"
         "code-generation.ss"
         "mreddesigner-misc.ss")

(provide (all-from-out "properties.ss"))

;; code-value
;; WARNING: the given proc MUST not use any value that is not defined in scheme/gui
;; because code generation won't be able to use anything else (if not included
; in the `requires' field of the project)

(define/provide container-classes
 (list frame% dialog% panel% pane%))

(define/provide shortcut-list
  (append '(#f)
          (string->list "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
          (list 'start
                'cancel
                'clear
                'shift
                'control
                'menu
                'pause
                'capital
                'prior
                'next
                'end
                'home
                'left
                'up
                'right
                'down
                'escape
                'select
                'print
                'execute
                'snapshot
                'insert
                'help
                'numpad0
                'numpad1
                'numpad2
                'numpad3
                'numpad4
                'numpad5
                'numpad6
                'numpad7
                'numpad8
                'numpad9
                'numpad-enter
                'multiply
                'add
                'separator
                'subtract
                'decimal
                'divide
                'f1
                'f2
                'f3
                'f4
                'f5
                'f6
                'f7
                'f8
                'f9
                'f10
                'f11
                'f12
                'f13
                'f14
                'f15
                'f16
                'f17
                'f18
                'f19
                'f20
                'f21
                'f22
                'f23
                'f24
                'numlock
                'scroll)))

(define/provide prop:shortcut%
  (class prop:one-of%
    (inherit-field value)
    (super-new [choices shortcut-list])

    ;; Instead of writing the whole list,
    ;; just write its name.
    ;; Of course, this means that `shortcut-values' must be accessible
    ;; when loading the file in template-load.ss, 
    ;; which is the case for "default-values.ss".
    (define/override (code-write)
      (list 'shortcut-values (code-write-value value)))
    ))

(define/provide (shortcut-values [val #f])
  (new prop:shortcut% [value val]))

;; This function will also be written (precode) in the generated code.
;; It must also be accessible (via require) at template loading.
(provide label-bitmap-proc)
(define/precode (label-bitmap-proc l)
  (let ([label (first l)]
        [image? (second l)]
        [file (third l)])
    (or (and image?
             (or (and file 
                      (let ([bmp (make-object bitmap% file 'unknown/mask)])
                        (and (send bmp ok?) bmp)))
                 "<Bad Image>"))
        label)))

;; TODO: this could be lightened with prop:proc-unquoted ?
(define/provide (label-bitmap-values [dft-text ""])
  (prop:proc
   (prop:group
    dft-text
    (prop:bool "Image?" #f)
    (prop:file #f)
    )
   label-bitmap-proc ; this proc MUST then be accessible in the generated code!!
   ))

;; Fonts

(provide list->font)
(define/precode (list->font l)
  (with-handlers ([exn:fail? (λ(e)
                               (send/apply the-font-list find-or-create-font
                                           ; try without the face name:
                                           (cons (first l) (rest (rest l))))
                               )])
    (send/apply the-font-list find-or-create-font l)
    ))

(define/provide (font->list ft)
  (list (send ft get-point-size)
        (send ft get-face)
        (send ft get-family)
        (send ft get-style)
        (send ft get-weight)
        (send ft get-underlined)
        (send ft get-smoothing)
        (send ft get-size-in-pixels)
        ))

(define/provide prop:font%
  (class prop:proc%
    (super-new )
    ))

;; We could also use (get-font-from-user)
;; which is a much better font chooser!
;; (that would need to make a specific prop:font%...
;; OR: use prop:proc with a function that is defined here!
(define/provide (font-values)
  (new prop:font%
       ; at first, there is no family !
       [value (flat-prop->prop '(8 default normal normal #f default #f))]
       ; we put it here because code-write is not yet able to remove fields!
       ; this should be easy though...
       [prop-code (prop:code list->font)]
       ))
  
;  (prop:proc
;    (prop:popup 
;     (prop:group
;      8 ; size [1-255]
;      (prop:one-of '(default decorative roman script
;                      swiss modern symbol system)
;                   'default) ; family
;      (prop:one-of '(normal italic slant) 'normal) ; style
;      (prop:one-of '(normal bold light) 'normal) ; weight
;      (prop:bool "underline?" #f) ; underline
;      (prop:one-of '(default partly-smoothed smoothed unsmoothed)
;                   'default) ; smoothing
;      (prop:bool "size in pixels?" #f) ; size-in-pixels? 
;      ))
;     font-proc
;    ))

(define/provide (alignment-values [horiz 'center] [vert 'top])
  (prop:group
   (prop:one-of '(left center right) horiz)
   (prop:one-of '(top center bottom) vert)))

(define/provide (prop:false-or-number v)
  (prop:proc-unquoted
   (prop:hgroup
    (and v #t) ; this is no mistake (I want it to write #t)
    (or v 0)
    )
   (λ(l)(and (first l) (second l)))
   ))

(define/provide (prop:false-or-string v)
  (prop:proc-unquoted
   (prop:hgroup
    (and v #t) ; this is no mistake (I want it to write #t)
    (or v "")
    )
   (λ(l)(and (first l) (second l)))
   ))
