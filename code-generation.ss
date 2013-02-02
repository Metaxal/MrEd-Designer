#lang scheme

;; ##################################################################################
;; # ============================================================================== #
;; # code-generation.ss                                                             #
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


(require "mred-id.ss"
         "code-write.ss"
         "mreddesigner-misc.ss"
         scheme/gui/base)

; Don't print quotes in the beginning of a (pretty-print '(list a b c))
(print-as-expression #f)

;; List of other things to write in the file before the init function
(define precode-list '())
(define (add-precode e)
  (set! precode-list (cons e precode-list)))

(provide precode)
(define-syntax-rule (precode arg ...)
  (add-precode (cons '(arg ...) precode-list)))

;; Use this form to define a function that should be added
;; in the generated file.
(provide define/precode)
(define-syntax-rule (define/precode (name arg ...) body ...)
  (begin
    (define (name arg ...) body ...)
    (add-precode '(define (name arg ...) body ...))
    ))
                      
(define (print-precode)
  (for-each (λ(e)(pretty-print e) (newline))
            (reverse precode-list)))
  


; ******************************************************
; * Code generation for exporting to files and console *
; ******************************************************

(define (module-header)
  (string-append "\
#lang racket/gui

;;==========================================================================
;;===                Code generated with MrEd Designer " application-version
                                                         "               ===
;;===              https://github.com/Metaxal/MrEd-Designer              ===
;;==========================================================================

") ; add the name of the project and the date ? and the username ?
; ;;===                 http://mred-designer.origo.ethz.ch                 ===
  )
 
(define (print-requires reqs)
  (display "(require\n")
  (for-each (λ(r)(printf " ~a\n" r))
            reqs)
  (display " )\n\n")
  )

;; Takes a list of top-level-windows and
;; generates the corresponding module.
;; tlw-list: list of top-level-window mred-id<%> widgets
(define/provide (generate-module mid [out (current-output-port)])
  (parameterize ([current-output-port out]
                 [use-runtime-paths? (send mid get-property-value 'runtime-paths?)])
    ; TODO: add the files `require'd, as defined in the project properties.
    (let* ([project-name (send mid get-id)]
           [children (send mid get-mred-children)]
           ; save original parents:
           [children-parents (map-send get-mred-parent children)]         
           ;; remove parents (i.e., the project-mid, which we don't want to be in the code):
           ;[_ (for-each-send (set-mred-parent #f) children)]
           [all-mred-ids (append-map get-all-children children)]
           ;[all-mred-ids (get-all-children mid)]
           ; the order of the widgets is correct for the following.
           [all-ids (map (λ(w)(send w get-id)) all-mred-ids)]
           [init-name (symbol-append* project-name "-init")]
           [provides (list* 'provide 
                            init-name
                            ; provide only ids that are checked
                            (append-map (λ(mid)(if (send (send mid get-property 'id) get-option)
                                                   (list (send mid get-id))
                                                   '()))
                                        all-mred-ids))]
           ;                           all-ids)]
           [all-defines (map (λ(id)(list 'define id #f))
                             (cons project-name all-ids))] ; we need the project to be defined as #f (for its direct children -> [parent #f])
           [all-options (append-map (λ(m)(send m generate-options))
                                    all-mred-ids)]
           [all-setters (map (λ(m)(send m generate-code)) 
                             all-mred-ids)]
           [pre-codes   (append-map (λ(m)(send m generate-pre-code))
                                    (cons mid all-mred-ids))] ; we need the project mid to be in here
           [post-codes  (filter-map (λ(m)(send m generate-post-code))
                                    (cons mid all-mred-ids))]
           [requires (send mid get-property-value 'code-requires)]
           [arguments all-options]
           )
      (display (module-header))
      (printf ";;; Call (~a) with optional arguments to this module\n\n" init-name)
      (print-requires requires)
      (pretty-print provides)
      (newline)
      (print-precode)
      (for-each pretty-print all-defines)
      (for-each pretty-print pre-codes)
      (pretty-print
       (append
        (list 'define (cons init-name arguments))
        all-setters
        post-codes
       ;shows
        ))
      
      ; restore original parents:
      (for-each (λ(c cp)(send c set-mred-parent cp))
                children
                children-parents)
      )))

; Callbacks and classes must be arguments of the initialization function.
; Could we add arbitrary parameters?
; dependant on the widget, and is a default value property ?

; ****************************************************
; * Code generation for saving projects and patterns *
; ****************************************************

;; Generates the save-code (e.g., to save projects, not the user-code) 
;; corresponding to the descending hierarchy 
(define/provide (write-mred-id-code mid)
  (let* ([save-parent (send mid get-mred-parent)]
         [parent-sym (gensym 'parent-)]
         [stub-parent (make-code-write-stub parent-sym)])
    ; replace the actual parent with a stub parent
    ; to avoid to get all the above hierarchy
    ; When code-written, it will write the parent-sym symbol instead.
    (send mid set-mred-parent stub-parent) 
    (let-values ([(code dico) (code-write-value (get-all-children mid) #t)])
      (begin0 
        ; return value:
        ; the value is a function that takes the parent of mid:
        (list 'lambda (list parent-sym);(list (first (dict-ref dico stub-parent)))
               code)
        ; restore parent:
        (send mid set-mred-parent save-parent)
        ))))

;; OBSOLETE (see template.ss/save-template)
;; Saves a mred-id% with all its children into a file
;(define/provide (save-mred-id mid file)
;  (let ([code (write-mred-id-code mid)])
;    ; compute the code beforehand in case there are some printings on the output
;    (with-output-to-file file
;      (λ()
;        (display
;         (string-append "; This file was generated with " 
;                        application-name-version "\n\n"))
;        (pretty-print code))
;      #:exists 'replace)))
