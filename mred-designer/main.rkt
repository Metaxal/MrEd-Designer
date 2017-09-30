#lang racket/gui

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - main.rkt                                                       #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
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

; See project-manager.rkt to build a package.

#| TODO (see also TODO.txt):
 - widgets: popup menu (?), message-box, put-file, get-file, get-color-from-user,
   get-font-from-user, get-text-from-user, get-choices from user, ...
   panel:vertical-dragable (+horiz), hierarchy-list, 
 - move-one-up, move-one-down in hierarchy (not really needed thanks to Copy/Cut/Paste ?)
 - Copy/paste w/o children ?
 - Plugins can add menu items ?
   e.g., the Project plugin adds Save, Load to the menu bar !
   Then, it should be specific to the project!
 - a "load template from file" button? (+ save)
   In the "Quick Templates" choice% appear the global templates (the one in the
   "templates" directory) + the templates that are in the same directory as the 
   opened project?
 - templates can be used as plugins : add a button in the correct box (Templates ?)
   if there is an associated image, use it
 - "Del" shortcut for "Delete" button
 - generate Stub Controller code ? printf of the method name
 - in template-load.rkt: generalize the require of plugin preview classes
   instead of an ad-hoc racket
 - return to default value: completely rewrite the default property!
   this is useful for updating from an old style
 - prop:range with a slider% for integers between 2 values
 - check ids duplicates when the user changes them!
 - integrate board.rkt (matrix +canvas) as a plugin
 - Images:
   - runtime-path
   - transparency
   - use text as tooltip over image


 General renamings to do:
 - for-each-send -> for-each/send (?)
 - map-send -> map/send (although : append-map)
 - code-gen-class -> widget-code-class (?)
 - mred-id -> med-id (?)
 - prop:... -> ??
 - code-write -> constructor-code ?
|#

(printf "~a: starting~n" application-name-version)

(require "mred-plugin.rkt"
         "property-frame.rkt"
         "toolbox-frame.rkt"
         "hierarchy-frame.rkt"
         "misc.rkt"
         "controller.rkt"
         "templates.rkt"
         )

; Modify the current directory to be the same as this file directory:
(require racket/runtime-path)
(define-runtime-path here-directory (build-path 'same))
(current-directory here-directory)


(set-debug #f)

; Load the widget plugins:
(load-mred-widget-plugins)

; Load the templates:
(make-template-dict)

(make-toolbox-frame
 #:exit-application-callback controller-exit-application
 #:plugin-button-callback    controller-create-mred-id
 #:generate-code-callback    controller-generate-code
 #:generate-code-to-console-callback controller-generate-code-to-frame
 #:new-project-callback      controller-new-project
 #:load-project-callback     controller-load-project
 #:save-project-callback     controller-save-project
 #:close-project-callback    controller-close-project
 #:add-template-callback     controller-load-template
 #:save-template-callback    controller-save-template
 #:replace-template-callback controller-replace-current-template
 #:delete-template-callback  controller-delete-template
 #:show-properties-callback  controller-show-property-frame
 #:show-hierarchy-callback   controller-show-hierarchy-frame
 #:cut-callback   controller-cut
 #:copy-callback  controller-copy
 #:paste-callback controller-paste
 )
(make-property-frame 
 toolbox-frame
 #:update-callback controller-replace-current-widget
 )
(make-hierarchy-frame 
 toolbox-frame
 #:on-select-callback controller-select-mred-id
 #:delete-callback    controller-delete-mred-id
 #:move-up-callback   controller-move-up
 #:move-down-callback controller-move-down
 #:cut-callback   controller-cut
 #:copy-callback  controller-copy
 #:paste-callback controller-paste
 #:show/hide-callback controller-show/hide
 )

(define no-project-loaded #t)
(for ([arg (current-command-line-arguments)])
  (match arg
    [(or "-d" "--debug")
     (set-debug #t)]
    [(regexp ".*\\.med$") 
     (printf "loading project ~a:" arg)
     (set! no-project-loaded #f)
     (load-project (string->path arg))
     ]
    [else (printf "Don't know what to do with command line argument: ~a\n" arg)]))

(when no-project-loaded
  (controller-new-project))

(show-toolbox-frame)
(show-property-frame)
(show-hierarchy-frame)
