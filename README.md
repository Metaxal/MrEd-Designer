# MrEd Designer 3.x

MrEd Designer is WYSIWYG program to create GUI applications for [Racket](http://www.racket-lang.org/) (ex PLT Scheme).

**Design principle:** The user should not have to modify the generated code manually. (Because this code is likely to be overwritten regularly.) If you do, then file an [issue](https://github.com/Metaxal/MrEd-Designer/issues).

**Documentation and screenshots:** https://github.com/Metaxal/MrEd-Designer/wiki

If you face difficulties with MrEd Designer or for any other comment you can contact me (laurent orseau gmail com) or file an [issue](https://github.com/Metaxal/MrEd-Designer/issues).

## Installation

In DrRacket: Select `File > Install a package...` and choose `mred-designer`.

Or from the command line, type:
```shell
raco pkg install mred-designer
```

## Quick Start

To start MrEd Designer, either type in the interactions window in DrRacket:
```racket
(require mred-designer)
```
or from the command line (recommended):
```shell
racket -l mred-designer
```

MrEd Designer starts with an empty project.

1. Click on the "frame" button ![Frame](https://raw.githubusercontent.com/Metaxal/MrEd-Designer/master/mred-designer/widgets/frame/icons/24x24.png) in the Main Panel (the one labelled "MrEd Designer" with all the buttons); this adds a frame to the project. The (small) frame appears on the screen and a new entry appears below the project name in the Hierarchy Panel.
2. Select the frame, either by clicking inside it, or by clicking on its name in the Hierarchy Panel. Several buttons become enabled in the Main Panel. Now click on the "button" button ![Frame](https://raw.githubusercontent.com/Metaxal/MrEd-Designer/master/mred-designer/widgets/button/icons/24x24.png). A button appears in the frame.
3. Click on this new button. It is now selected in the Hierarchy Panel, and the Properties Panel displays various modifiable information about the button. In front of "label", change the label from "Button" to "Click me!". Click on `Apply&Update Preview`.
4. Click on `File > Generate Racket file...` and save the code to some place, say in `my-project-GUI.rkt`. (Note that this only generates a Racket file but does not save your MrEd Designer project for further editing--use `File > Save Project` for this.) 
5. Now, either open `my-project-GUI.rkt` in DrRacket and execute it, or call on the command line with `racket my-project-GUI.rkt`. You should see the frame that you have created.

<p align="center">
<img src="https://raw.githubusercontent.com/Metaxal/MrEd-Designer/master/mred-designer/images/screenshots/click-me-frame.png" alt="A frame with a button">
</p>

## Creating your program logic

Once `my-project-GUI.rkt` is generated, you can write your program logic in a separate module, say `my-project-logic.rkt` (here we assume the two files are in the same directory).
Write the following code in this new file:
```racket
#lang racket
(require "my-project-GUI.rkt")

(project-1488-init
 #:button-1689-callback
 (λ(bt ev)
   (send bt set-label "It works!")))
```
Make sure you change the numbers accordingly (see inside `my-project-GUI.rkt`), or better yet in MrEd Designer change the *names* of the project and the button to something more meaningful in the Properties Panel (don't forget to click `Apply&Update Preview` and then `File > Generate Racket file...`).

> Do not modify the file `my-project-GUI.rkt` manually, as you will likely re-generate this file several times from within MrEd Designer, thus overwriting any change you may have done!

Execute `my-project-logic.rkt`, the frame and button should appear. Click on the button. The button's label should now say "It works!".


