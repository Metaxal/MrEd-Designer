#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # mred-plugin.rkt                                                                #
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

#| WARNING! (compilation)

If this file is modified, all the plugins should be recompiled by hand!
MrEd will NOT do it itself!

To force the recompilation of all the widgets, call:
(touch-plugin-files)
|#

(require "plugin.rkt"
         "mred-id.rkt"
         "properties.rkt"
         "mreddesigner-misc.rkt"
         )

; A plugin must return an instance of this class
; (you should use make-plugin)
(define/provide mred-plugin%
  (class object% (super-new)
    (init-field 
      type
      tooltip
      button-group ; MUST be a string!
      [(make-properties-var make-properties)]
      widget-class
      widget-class-symbol ; the class used to generate the widget in MED
      code-gen-class-symbol ; the class used for the widget in the generated code
      parent-widget-class ; see: can-instantiate?
      parent-widget-class-symbol
      pre-code
      post-code
      ;[callback default-callback]
      ;[image "button.png"]
      )
    (field 
      [dir-name #f]
      ;[default-values (make-properties)]
      [make-widget-proc #f]
      [icon-bitmap #f]
      )
    
    (getter type tooltip button-group 
            widget-class-symbol code-gen-class-symbol
            widget-class parent-widget-class parent-widget-class-symbol)
    (getter/setter icon-bitmap dir-name)
    
    ;; Used by templates (when loaded, to change the default names)
    ;; But not used by mred-ids when created.
    (define/public (get-random-id)
      (gensym (symbol-append* type '-)))
    
    ;; Creates a new set of default properties:
    (define/public (make-properties) (make-properties-var))
    
    (define/public (set-make-widget props) (set! make-widget-proc props))
    ;; Creates a new (preview/user) widget from a parent and a set of properties:
    (define/public (make-widget mred-id parent [properties (make-properties)])
;      (debug-printf "make-widget: [mred-id ~a] [parent ~a]\n"
;                    (send mred-id get-id) 
;                    (and parent 
;                         (let ([par (send parent get-mred-id)])
;                           (and par (send par get-id)))))
      (make-widget-proc mred-id parent properties))

    ;; Creates a new widget-holder.
    (define/public (new-mred-id mid-parent)
      ; cannot instantiate a new mred-id if the parent
      ; does not match the required class(es)
      (and (can-instantiate? mid-parent)
           ; return value:
           (new mred-id%
                [plugin this] 
                [mred-parent mid-parent]
                [properties (make-properties)])))
    
    ;; Can we add a new mred-id to parent?
    ;; To know, check the parent-widget-class field
    (define/public (can-instantiate? mid-parent)
      (can-instantiate-under? mid-parent parent-widget-class)
      )
    
    (define/public (generate-pre-code mid)
      (pre-code mid))
    
    (define/public (generate-post-code mid)
      (post-code mid))
    
    ))

;; Is it possible to instantiate a mred-id/widget under mid-parent,
;; if the mred-id/widget specifies the possible parent-widget-classes?
(define/provide (can-instantiate-under? mid-parent parent-widget-class)
  (let ([mid-parent-widget (and mid-parent (send mid-parent get-widget))]
        [mid-parent-class (and mid-parent 
                               (send (send mid-parent get-plugin)
                                     get-widget-class))])
    (or 
      ; always possible if #t :
      (eq? #t parent-widget-class) 
      ; if #f, then parent must also be #f :
      (and (not mid-parent-class) 
           (not parent-widget-class)) 
      ; if given a class, ok if mid-parent inherits the given class :
      (and (class? parent-widget-class)
           (subclass? mid-parent-class parent-widget-class))
      ; if given a list, ok if one of the options is ok :
      (and (list? parent-widget-class) 
           (ormap (λ (one-parent-class) (can-instantiate-under? mid-parent one-parent-class))
                  parent-widget-class))
      ; if given a procedure, ok if the result of the proc is ok :
      (and (procedure? parent-widget-class) 
           (parent-widget-class mid-parent-widget));mid-parent-class))
      )))

;; Returns a pair (field-id . (prop:field-id% prop))
(define (make-prop:field-pair field-id prop options necessaries no-codes hiddens)
  (cons field-id 
        (new prop:field-id% 
             [value (flat-prop->prop prop)]
             [field-id field-id]
             [option    (member? field-id options)]
             [necessary (member? field-id necessaries)]
             [no-code   (member? field-id no-codes)]
             [hidden    (member? field-id hiddens)]
             )))

; **********************
; * Main Plugin Syntax *
; **********************

;; Macro to use in a plugin:
;; defines a list of [id default-value] 
;; and automatically makes the default-preview constructor.
;; WARNING! 'parent' must not be in the field-id !
;; it will be set automatically from above.
(provide make-plugin)
(define-syntax-rule (make-plugin [mred-field val] ...
                                 ([field-id prop] ...)
                                 )
  (begin
    (provide plugin-widget)
    (define plugin-widget #f)
    (let* ([mred-fields        (list [list 'mred-field val] ...)]  ; assoc-list of the first fields
           [mred-quoted-fields (list [list 'mred-field 'val] ...)] ; idem but values are quoted
           [mred-ref           (λ(id [dft (λ()(error "key not found in mred-ref:" id))])
                                 (assoc-ref mred-fields id dft))] ; get a field value given field-id
           [mred-quoted-ref    (λ(id [dft (λ()(error "key not found in mred-quoted-ref:" id))])
                                 (assoc-ref mred-quoted-fields id dft))] ; get a field value given field-id
           [type                  (mred-ref 'type)]
           [widget-class-symbol   (mred-quoted-ref 'widget-class)]
           [code-gen-class-symbol (mred-quoted-ref 'code-gen-class widget-class-symbol)]
           ;; Fields that will be options of the generated init-function code :
           [options            (mred-ref 'options '(callback))]
           [necessaries        (mred-ref 'necessary '())]
           ;; Fields that will not be included in the code generation :
           ;[no-codes           (list* 'id 'code-class 'code-gen-class (mred-ref 'no-code '()))] 
           [no-codes           (list* 'id (mred-ref 'no-code '()))] ; NOT 'code-gen-class, see mred-id.rkt/generate-code
           [hiddens            (mred-ref 'hidden '())]
           [make-field-pair    (λ(id p)(make-prop:field-pair 
                                        id p options necessaries no-codes hiddens))]
           )
      ; Create the plugin object:
      (set! plugin-widget
            (new mred-plugin% 
                 [type                  type]
                 [tooltip               (mred-ref 'tooltip)]
                 [button-group          (mred-ref 'button-group)]
                 [widget-class          (mred-ref 'widget-class)]
                 [widget-class-symbol   widget-class-symbol];(mred-quoted-ref 'widget-class)]
                 [code-gen-class-symbol code-gen-class-symbol];(mred-quoted-ref 'code-gen-class widget-class-symbol)]
                 [parent-widget-class   (mred-ref 'parent-class #t)]
                 [parent-widget-class-symbol (mred-quoted-ref 'parent-class #t)]
                 [pre-code              (mred-ref 'pre-code  (λ()(λ(mid)'())))] ;must return a list of exprs, as if it was beginning with `begin'
                 [post-code             (mred-ref 'post-code (λ()(λ(mid)#f)))]
                 [make-properties       
                  (λ()(list 
                       (make-field-pair 'id (gensym (symbol-append* type '-)))
                       (make-field-pair 'code-gen-class (new prop:code% [value code-gen-class-symbol]
                                                             [value-code code-gen-class-symbol]))
                       (make-field-pair 'field-id prop)
                       ...))]
                 ))
      
      ; create the default values of the properties:
      (let ([properties-default (send plugin-widget make-properties)])
      ; set the plugin method for creating new widgets from it:
        (send plugin-widget set-make-widget
              (λ(mred-id parent properties)
                (new (mred-widget%% (mred-ref 'widget-class))
                     [mred-id mred-id]
                     [parent   parent]
                     [field-id (send (dict-ref 
                                      properties 'field-id
                                      ; if not found, use default:
                                      (λ()(dict-ref properties-default 'field-id)))
                                     get-value)]
                     ...
                     ))
              ))
      ))
    )

(define plugin-dict '()); (make-hash))
(define/provide (get-widget-plugins)
  (map cdr plugin-dict))
;  (hash-values plugin-hash)) ; the list of loaded plugins
(define (add-plugin p)
  (set! plugin-dict 
        (append plugin-dict (list (cons (send p get-type) p)))))

(define/provide (get-widget-plugin type)
  (dict-ref plugin-dict type #f))

(define/provide widget-plugins-path "widgets") ; relative to base directory
(define/provide widget-icons-dir "icons")

(define/provide (load-mred-widget-plugins) ;-> list of widget plugins
  (load-plugins 
    widget-plugins-path 
    (λ (dir-name)
      (debug-printf "loading plugin: ~a\n" dir-name)
      (let ([p (dynamic-require "widget.rkt" 'plugin-widget)])
        (send p set-dir-name dir-name)
        (send p set-icon-bitmap
             (make-object bitmap% 
               (build-path widget-icons-dir "16x16.png")
               'png))
       (add-plugin p)
;       (hash-set! plugin-hash (send p get-type) p)
       ))
    )
  (void)
  )

;; when this file has changed,
;; call this function to force the recompilation of all the plugins
(define (touch-plugin-files)
  (load-plugins 
     widget-plugins-path 
     (λ (dir-name)
       (let ([file (build-path "widget.rkt")])
         (debug-printf "plugin: ~a ~a\n" 
                       dir-name 
                       (file-exists? file))
         (file-or-directory-modify-seconds 
            file
            (current-seconds))
         )
       )
     ))
                                       
#| TESTS: | #
(load-mred-widget-plugins)
(define pframe (get-widget-plugin 'frame))
(define pbutton (get-widget-plugin 'button))
(define mred1 (send pframe new-mred-id #f))
(define mred2 (send pbutton new-mred-id mred1))
;|#
