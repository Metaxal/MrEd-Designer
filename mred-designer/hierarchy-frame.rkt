#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # hierarchy-frame.rkt                                                            #
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

(require "misc.rkt"
         mrlib/hierlist)

(define/provide hierarchy-frame #f)
(define/provide hierarchy-widget #f)
(define on-select-callback #f)
(define delete-callback #f)

(define/provide (make-hierarchy-frame 
                 parent
                 #:on-select-callback on-select-cb
                 #:delete-callback    delete-cb
                 #:move-up-callback   move-up-cb
                 #:move-down-callback move-down-cb
                 #:cut-callback   cut-callback
                 #:copy-callback  copy-callback
                 #:paste-callback paste-callback
                 #:show/hide-callback show/hide-callback
                 )
  (set! on-select-callback on-select-cb)
  (set! hierarchy-frame
        (new frame% 
             [label "Hierarchy"]
             [parent parent]
             [x 5]
             [y 405]
             [min-width 250]
             [min-height 400]
             ))
  (let ([hp (new horizontal-panel% 
                 [parent hierarchy-frame]
                 [stretchable-height #f])])
    (new button% [parent hp] [label "Delete"] 
         [callback (λ _ (delete-cb))])
    (new button% [parent hp] [label "Cut"]
         [callback (λ _ (cut-callback))])
    (new button% [parent hp] [label "Copy"]
         [callback (λ _ (copy-callback))])
    (new button% [parent hp] [label "Paste"]
         [callback (λ _ (paste-callback))])
    (new button% [parent hp] [label "Show/Hide"]
         [callback (λ _ (show/hide-callback))])
    (new button% [parent hp] [label (image-file->bitmap "hierarchy-up.png")]
         [callback (λ _ (move-up-cb))])
    (new button% [parent hp] [label (image-file->bitmap "hierarchy-down.png")]
         [callback (λ _ (move-down-cb))])
    )
  (set! hierarchy-widget
        (new mred-id-hlist%
             [parent hierarchy-frame]
             [style '(auto-vscroll auto-hscroll)]
             ))
  )

(define/provide (show-hierarchy-frame)
  (send hierarchy-frame show #t))

;;; Generic function for hierarchical-list-items

;; Sets the item with a given label and an associated data.
;; Now not so generic...
(define (set-hlist-item-label item label [data (send item user-data)])
  (send item user-data data)
  (let ([ed (send item get-editor)])
    (send ed erase)
    (send ed insert (make-object image-snip% 
                      (send (send data get-plugin) get-icon-bitmap)))
    (send ed insert label)
    item))

(define (hlist-add-item hl label [data #f])
  (let ([it (send hl new-item)])
    (set-hlist-item-label it label data)
    it))

(define (hlist-add-hlc hl label [data #f])
  (let ([it (send hl new-list)])
    (set-hlist-item-label it label data)
    it))

(define mred-id-hlist%
  (class hierarchical-list%
    (super-new)
    
    ; do not call on-select when select is called:
    (send this on-select-always #f)
    
    (define mred-id-items (make-hash))
    
    (define (get-mred-id-item mid) 
      (hash-ref mred-id-items mid #f))
    
    (define (add-mred-id-item mid it) 
      (set-hlist-item-label it (->string (send mid get-id)) mid)
      (hash-set! mred-id-items mid it))
    
    (define (remove-mred-id-item mid) 
      (hash-remove! mred-id-items mid))
    
    (define (replace-mred-id-item mid new-it)
      (debug-printf "replace-mred-id-item: ~a ~a\n" mid new-it)
      ; WATCH OUT! prevents from Garbage Collecting if entries are not deleted!
      (hash-set! mred-id-items mid new-it))
    
    (inherit get-selected select delete-item)

    ;; Add wrapper around add-child to bracket changes with begin/end edit/container sequences - kdh 2012-02-29
    ;; If parent is #f, then the parent is the hierarchy-list itself.
    ;; parent-mid: (or/c 'selected 'none mred-id%?)
    (define/public (add-children mid [parent-mid 'selected])
      (debug-printf "add-children: ~a parent:~a\n" mid parent-mid)
      (send hierarchy-frame begin-container-sequence)
      (send (send this get-editor) begin-edit-sequence #f)
      (add-child mid
                 (case parent-mid
                   [(selected) (or (get-selected) this)]
                   [(none) this]
                   [else (get-mred-id-item parent-mid)]))
      (send (send this get-editor) end-edit-sequence)
      (send hierarchy-frame end-container-sequence)
      (debug-printf "add-children: exit\n"))

    ;; Recursively adds a child and its children to the given hlist parent.
    ;; Alter add-child to enforce access through add-children wrapper - kdh 2012-02-29
    (define (add-child mid hl-parent)
      (debug-printf "hl-parent: ~a\n" hl-parent)
      (define mred-children (send mid get-mred-children))
      (define new-hlc (send hl-parent new-list))
      ; if the mred-id has children, add them too:
      (for ([c (in-list mred-children)])
        (add-child c new-hlc))
      (add-mred-id-item mid new-hlc)
      ; Open the list only after adding all the children - kdh 2012-02-29
      ; This seems buggy currently. Not sure why. Upstream?
      #;(send new-hlc open))
    
    (define/override (on-select i)
      (on-select-callback (send i user-data)))
        
    (define/public (set-selected-mred-id w)
      (when w
        (select (get-mred-id-item w))))

    (define/public (update-current-mred-id)
      (let* ([it (get-selected)]
             [mid (send it user-data)])
        (set-hlist-item-label it (->string (send mid get-id)))))
   
    ;; Finds the parent hierarchy-list-compound-item<%> of the given item. 
    (define/public (find-parent it [hlist this])
      (cond [(not (or (is-a? hlist hierarchical-list-compound-item<%>)
                      (is-a? hlist hierarchical-list%)))
             #f]
            [(memq it (send hlist get-items))
             hlist]
            [else (ormap (λ(i)(find-parent it i))
                         (send hlist get-items))]))
   
    (define/public (delete-mred-id mid)
      (let* ([it (get-mred-id-item mid)]
             [it-parent (find-parent it)])
        (if it-parent
            (send it-parent delete-item it)
            (printf "ERROR: it not found!\n"))
        (remove-mred-id-item mid)
        ))
    
    (define/public (change-children hlist [changer (λ (l) l)])
      ; Bracket changes to hierarchy list with begin/end edit/container sequences - kdh 2012-02-29
      (debug-printf "change-children: enter\n")
      (send hierarchy-frame begin-container-sequence)
      (send (send this get-editor) begin-edit-sequence #f)
      (let* ([l (send hlist get-items)]
             [l2 (changer l)])
        ; remove all items (yes, hierarchical-list% lacks many useful features...)
        (for-each (λ (it) (send hlist delete-item it)) l)
        
        (for-each (λ (x) (let ([new-x (if (is-a? x hierarchical-list-compound-item<%>)
                                          (send hlist new-list)
                                          (send hlist new-item))])
                           (send new-x user-data (send x user-data))
                           (send (send x get-editor) copy-self-to (send new-x get-editor))
                           (replace-mred-id-item (send x user-data) new-x)
                           ; also recreate all the following hierarchy...
                           (when (is-a? x hierarchical-list-compound-item<%>)
                             (change-children new-x (λ _ (send x get-items)))
                             ; Open the new item only after adding all children - kdh 2012-02-29 
                             (if (send x is-open?)
                                 (send new-x open)
                                 (send new-x close)))))
                  l2))
      (send (send this get-editor) end-edit-sequence)
      (send hierarchy-frame end-container-sequence)
      (debug-printf "change-children: exit\n")
      )
    
    (define/public (move-item it list-mover)
      ; Bracket changes to hierarchy list with begin/end edit/container sequences - kdh 2012-02-29
      (debug-printf "move-item:\n")
      (send hierarchy-frame begin-container-sequence)
      (send (send this get-editor) begin-edit-sequence #f)
      (let* ([mid (send it user-data)]
             [it-parent (find-parent it)])
        (when it-parent
          (change-children it-parent
                           (λ(l)(list-mover l it))))
        (set-selected-mred-id mid)
        )
      (send (send this get-editor) end-edit-sequence)
      (send hierarchy-frame end-container-sequence)
      )
    
    (define/public (move-up)
      (move-item (get-selected) list-move-left))

    (define/public (move-down)
      (move-item (get-selected) list-move-right))
    ))

(define/provide (hierarchy-select w)
  (send hierarchy-widget set-selected-mred-id w))
