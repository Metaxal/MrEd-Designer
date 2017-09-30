#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - misc.rkt                                                       #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
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

(require racket/gui/base)

;; Defines a function or a variable and provides it at the same time.
(provide define/provide)
(define-syntax define/provide
  (syntax-rules ()
    ; function case:
    [(_ (name args ... . l) body ...)
     (begin (provide name)
            (define (name args ... . l) body ...))]
    ; variable case:
    [(_ name val)
     (begin (provide name)
            (define name val))]
    ))

;; Current version of MrEd Designer
(define/provide application-version-maj 3)
(define/provide application-version-min 15)
(define/provide application-version (format "~a.~a" application-version-maj application-version-min))
(define/provide application-name "MrEd Designer")
(define/provide application-name-version
  (string-append application-name " " application-version))

;; Defines a mock (a substitute) for a function.
;; When called, the function only prints a warning.
;; The body part is ripped off.
(provide define/provide-mock)
(define-syntax-rule (define/provide-mock (name args ...) body ...)
  (begin (provide name)
         (define (name args ...)
           (printf "~a: NOT IMPLEMENTED ; arg-list: ~a\n"
                   'name
                   (list args ...)))))

(define/provide debug #f)
(define/provide (set-debug dbg) (set! debug dbg))
(define/provide (debug-printf . r)
  (when debug
    (apply printf r)))

;; Loads the images when necessary
;; Stores them in a hash for re-use
(define image-hash (make-hash))
(define/provide (image-file->bitmap filename)
  (hash-ref! image-hash filename
             (make-object bitmap% (build-path "images" filename))))

(define/provide (atom? val)
  (or (number? val) (symbol? val) (string? val) (boolean? val)))

;; Converts any value into a string
(define/provide (->string x)
  (cond [(string? x) x]
        [(number? x) (number->string x)]
        [(symbol? x) (symbol->string x)]
        [(path? x)   (path->string x)]
        [else        (format "~a" x)]))

(define/provide to-string ->string)

(define/provide (string-append* . l)
  (apply string-append (map ->string l)))

(define/provide (symbol-append* . l)
  (string->unreadable-symbol (apply string-append* l)))

(define/provide (symbol->keyword sym)
  (string->keyword (symbol->string sym)))

(define/provide (assoc-ref l key [default-val
                                   (λ()(error "key not found in assoc-ref:" key))])
  (let ([v (assoc key l)])
    (if v
        (second v)
        (if (procedure? default-val)
            (default-val)
            default-val)
        )))

(define/provide (assoc-remove lst id-list)
  (cond
    ((null? lst) '())
    ((and (list? (car lst)) (member (caar lst) id-list))
     (assoc-remove (cdr lst) id-list)
     )
    (else
     (cons (car lst) (assoc-remove (cdr lst) id-list))
     )
    )
  )

(define/provide (assoc-change lst old-id new-id)
  (cond
    ((null? lst) '())
    ((and (list? (car lst)) (equal? (caar lst) old-id))
     (cons (cons new-id (cdar lst)) (assoc-change (cdr lst) old-id new-id))
     )
    (else
     (cons (car lst) (assoc-change (cdr lst) old-id new-id))
     )
    )
  )

(define/provide (hash-keys-values h)
  (match h
    [(hash-table [keys vals] ...)
     (values keys vals)]))

(define/provide (hash-keys h)
  (match h
    [(hash-table [keys values] ...)
     keys]))

(define/provide (hash-values h)
  (match h
    [(hash-table [keys values] ...)
     values]))

(define/provide (member? x l)
  (if (member x l) #t #f))

;; Returns the first position of element e in list l,
;; or #f if not found.
(define/provide (list-pos l e)
  (for/first ([x l]
              [i (in-naturals)]
              #:when (equal? e x))
    i))

;; Splits l on (first mathc of) element e
(define/provide (split-at-element l e [compare? equal?])
  (split-at l (list-pos l e)))
;  (let loop ([left '()]
;             [right l])
;    (cond [(empty? right) (error "Element not found in split-at-element: " e)]
;          [(compare? e (first right))
;           (values (reverse left) e (rest right))]
;          [else (loop (cons (first right) left)
;                      (rest right))])))

;; Moves the element e one position to the left in the list l.
(define/provide (list-move-left l e)
  (let*-values ([(left right) (split-at-element l e)]
                [(rleft) (reverse left)])
    (if (empty? left)
        l ; no change
        (append (reverse (rest rleft))
                (list e)
                (cons (first rleft) (rest right))))))

(define/provide (list-move-right l e)
  (reverse (list-move-left (reverse l) e)))

(define/provide (text-split-with-empty str ch empty)
  (let*
      ((idx (string-length str))
       (last #f)
       (slist '())
       )
    (do () ( (not (>= idx 0)) )
      (set! last idx)
      (do () ( (not (and (> idx 0)
                         (not (or (and (char? ch)
                                       (char=? (string-ref str (- idx 1)) ch))
                                  (and (list? ch)
                                       (member (string-ref str (- idx 1)) ch))
                                  )
                              )
                         )
                    ) )
        (set! idx (- idx 1))
        )
      (when (>= idx 0)
        (when (or empty
                  (and (not empty) (> (- last idx) 0)) )
          (set! slist (cons (substring str idx last) slist))
          )
        (set! idx (- idx 1))
        )
      )
    slist
    )
  )

(define/provide (path-string->string pstr)
  (if (path? pstr)
      (path->string pstr)
      pstr))

;; list list -> prefix l1-rest l2-rest
;; prefix: a list of the first equal elements of l1 and l2
;; l1-rest and l2-rest are the remaining elements after prefix
(define/provide (most-common-prefix l1 l2)
  (let loop ([prefix '()]
             [l1 l1]
             [l2 l2])
    (cond [(or (empty? l1) (empty? l2)
               (not (equal? (first l1) (first l2))))
           (values prefix l1 l2)]
          [else (loop (append prefix (list (first l1)))
                      (rest l1)
                      (rest l2))])))

;; base-dir: string-or-path, base directory.
;; a-path: string-or-path, file or directory
;; -> path?, a path that represents a-path, relatively to base-dir
(define/provide (relative-path base-dir path)
  (let ([lbase (explode-path (normal-case-path (simple-form-path base-dir)))]
        [lpath (explode-path (normal-case-path (simple-form-path path)))])
    (let-values ([(common rest-base rest-path)
                  (most-common-prefix lbase lpath)])
      (apply build-path (append (map (λ _ 'up) rest-base) rest-path))
    )))

#| Tests: | #
(relative-path
 "/a/b/c/d/f/g"
 "/a/b/c/d/e/g/h")
-> #<path:../../e/g/h>
;|#

;; Writes a path constructor from a path
(define/provide (write-path p)
  (cons 'build-path
        (map (λ(p-elt)(cond [(symbol? p-elt) (list 'quote p-elt)]
                            [(absolute-path? p-elt) (path->string p-elt)]
                            [else (path-element->string p-elt)]))
             (explode-path p))))

#|
> (build-path 'same 'up "a" "b")
#<path:./../a/b>
> (write-path (build-path 'same 'up "a" "b"))
'(build-path 'same 'up "a" "b")
|#

;; Used in properties.rkt (prop:file%) and code-generation.rkt
(define/provide use-runtime-paths? (make-parameter #f))

;; What is the mid being processed?
;; Usefull for some property widgets like pwig:file%
(define/provide current-property-mred-id (make-parameter #f))

;; takes a list of codes and generates code accordingly.
;; if no code -> #f
;; if one expr -> this expr
;; if several exprs -> (begin expr ...)
(define/provide (generate-begin-code codes)
  (cond [(not codes) #f]
        [(empty? codes) #f]
        [(empty? (rest codes)) (first codes)]
        [else (cons 'begin codes)]
        ))

;; Try ... catch ... finally
;; Finally is executed before the catch.
(provide try)
(define-syntax try
  (syntax-rules (catch finally)
    [(try
      try-body ...
      (catch
          [exn exn-handler] ...
        )
      (finally
       final-body ...))
     ; =>
     (with-handlers ([exn exn-handler] ...)
       (with-handlers ([exn? (λ(e)final-body ...
                                    (raise e))])
         try-body ...))
     ]
    [(try t ... (finally f ...))
     (try t ... (catch) (finally f ...))]
     ))

; ***********************
; * Classes and Objects *
; ***********************

;; Sends the same message to all the objects of the list.
;; (map get-value list-of-valued-objects)
;; (map (set-value 10) list-of-valued-objects)
(provide map-send)
(define-syntax map-send
  (syntax-rules ()
    [(_ (arg ...) l)
     (map (λ(x)(send x arg ...)) l)]
    [(_ id l)
     (map (λ(x)(send x id)) l)]
    ))

(provide for-each-send)
(define-syntax for-each-send
  (syntax-rules ()
    [(_ (arg ...) l)
     (for-each (λ(x)(send x arg ...)) l)]
    [(_ id l)
     (for-each (λ(x)(send x id)) l)]
    ))

;; Returns a string from a value.
;; Syntax objects are turned into data.
(define-for-syntax (->string x)
  (cond [(syntax? x) (->string (syntax->datum x))]
        [else (format "~a" x)]
        ))

;; Turns all the arguments into strings, append them
;; And return the corresponding symbol.
(define-for-syntax (symbol-append* . args)
  (string->symbol
   (apply string-append (map ->string args))))


;; From a identifier in a class, defines a (get-<id>) method
;; that returns the value of the <id>.
;; Several ids can be given.
;; See also the built-in get-field macro.
(provide getter)
(define-syntax (getter stx)
  (syntax-case stx ()
    [(_ id)
     (with-syntax ([get-id (symbol-append* "get-" #'id)])
       #'(define/public (get-id) id))]
    [(_ id1 id2 ...)
     #'(begin (getter id1)
              (getter id2 ...))]
    ))

;; Defines a setter (set-<id> val) that sets the <id> field to val.
;; Several ids can be given.
(provide setter)
(define-syntax (setter stx)
  (syntax-case stx ()
    [(_ id)
     (with-syntax ([get-id (symbol-append* "set-" #'id)])
       #'(define/public (get-id val) (set! id val))
       )]
    [(_ id1 id2 ...)
     #'(begin (setter id1)
              (setter id2 ...))]
    ))

;; Helper to define both a getter and a setter for given field ids.
(provide getter/setter)
(define-syntax-rule (getter/setter arg ...)
  (begin (getter arg ...)
         (setter arg ...)))

; *******
; * GUI *
; *******

;; Closes a top-level-window.
(define/provide (close-window tlw)
  (when (send tlw can-close?)
    (send tlw on-close)
    (send tlw show #f)))
