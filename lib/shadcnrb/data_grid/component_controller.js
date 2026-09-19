import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--data-grid--component
// Rows that arrive after the page (a Turbo stream appending to the body) are
// stamped from the header: each heading carries its column's cell classes
// and label, so the rows need no column knowledge of their own.
// Fixed header: header and footer are grids outside the scrolling body, so
// both scrollbars sit on the rows. Heading widths become minimums on the
// first full row's cells, so the body's tracks size to the wider of heading
// and values; the resolved tracks are then copied to the header and footer,
// as rows load or the container resizes.
// Selection: one cell is selected. A click or the arrow keys move it,
// Home/End jump within the row, Ctrl+Home/End to the corners; it is kept in
// view, clear of pinned columns. Cells marked `data-selectable="false"` are
// skipped. If the selected cell leaves the DOM, the cell at its position
// takes over.
// Editing belongs to the app; the grid reports intent and stays out of the
// way. Events, all `data-grid:` prefixed and cancelable, carry elements in
// `detail`: `select` {from, to, row, column}; `activate` {cell, via, key} on
// Enter, F2, double-click or a typed key; `commit` {cell} on Enter and
// `cancel` {cell} on Escape while editing; `leave` {cell, to} when focus
// leaves an editing cell. With `editor` naming a controller on the same
// element, the grid also calls its method of the same name with the detail.
// A cell is editing while focus sits inside it rather than on it, or while
// the app sets `data-mode="editing"` on it; arrows, Enter and Escape then
// belong to the editor, and the cell stops truncating.
export default class extends Controller {
  static targets = ["header", "body", "footer"]
  static values = { editor: String }

  connect() {
    this.rowObserver = new MutationObserver((mutations) => this.rowsChanged(mutations))
    this.rowObserver.observe(this.element, { childList: true, subtree: true })
  }

  bodyTargetConnected(body) {
    this.sizeObserver ??= new ResizeObserver(() => this.align())
    this.sizeObserver.observe(body)
  }

  bodyTargetDisconnected(body) {
    this.sizeObserver.unobserve(body)
  }

  disconnect() {
    this.rowObserver.disconnect()
    this.sizeObserver?.disconnect()
  }

  rowsChanged(mutations) {
    const rows = mutations.flatMap(({ addedNodes }) => [...addedNodes])
      .filter((node) => node.nodeType === Node.ELEMENT_NODE)
      .flatMap((node) => (node.matches(ROW) ? [node] : [...node.querySelectorAll(ROW)]))
    rows.forEach((row) => this.stamp(row))
    if (rows.length > 0 && this.hasBodyTarget) this.align()
    this.reselect()
  }

  // The heading's class list is the merged base + column set the server
  // renders, so the base classes are swapped for it; rows the server already
  // styled come out unchanged.
  stamp(row) {
    const grid = this.grid
    const heads = [...grid.querySelectorAll("[role=columnheader]")]
    if (row.children.length !== heads.length) return

    const base = grid.dataset.cellClass.split(" ")
    const selectable = grid.dataset.selectableClass?.split(" ")
    ;[...row.children].forEach((cell, i) => {
      const head = heads[i]
      if (!head) return

      cell.classList.remove(...base)
      cell.classList.add(...head.dataset.cellClass.split(" "))
      if (head.dataset.label) cell.dataset.label = head.dataset.label
      if (head.dataset.truncate) this.tooltip(cell)
      if (!selectable) return

      cell.setAttribute("role", "gridcell")
      if (cell.dataset.selectable === "false") cell.classList.remove(...selectable)
      else cell.tabIndex = -1
    })
  }

  // The truncating cell's content moves into a cloned tooltip root, with
  // the text as the panel.
  tooltip(cell) {
    const template = this.grid.querySelector("template[data-slot=data-grid-tooltip]")
    if (!template || cell.querySelector("[data-slot=tooltip]")) return

    const root = template.content.firstElementChild.cloneNode(true)
    const panel = root.querySelector("[data-slot=tooltip-content]")
    panel.prepend(cell.textContent.trim())
    root.prepend(...cell.childNodes)
    cell.replaceChildren(root)
  }

  // Minimums go on cells, not tracks: a track with a fixed minimum only grows
  // from free space. Flexible columns carry their own floor. In card mode the
  // body has a single implicit track, so the minimums come off.
  align() {
    const body = this.bodyTarget
    this.grids.forEach((grid) => (grid.style.gridTemplateColumns = ""))
    const tokens = getComputedStyle(body).getPropertyValue("--cols").trim().match(/minmax\([^)]*\)|\S+/g) ?? []
    const row = [...body.children].find((candidate) => candidate.children.length === tokens.length)
    const cards = tracks(body).length !== tokens.length
    const wanted = cards || !this.hasHeaderTarget ? [] : tracks(this.headerTarget)
    if (row) {
      [...row.children].forEach((cell, i) => {
        cell.style.minWidth = wanted[i] && !tokens[i].startsWith("minmax(") ? `${wanted[i]}px` : ""
      })
    }

    if (cards) return

    const resolved = getComputedStyle(body).gridTemplateColumns
    this.grids.forEach((grid) => (grid.style.gridTemplateColumns = resolved))
  }

  pan() {
    this.grids.forEach((grid) => (grid.scrollLeft = this.bodyTarget.scrollLeft))
  }

  select(event) {
    const cell = event.target.closest(SELECTABLE)
    if (cell && !editing(cell)) this.focusCell(cell)
  }

  // The grid is the tab stop and hands focus on to the selected cell.
  enter(event) {
    if (event.target === this.grid) this.focusCell(this.selected ?? this.cells[0])
  }

  // Focus on a cell selects it; focus inside a cell means its editor is up.
  focused(event) {
    const cell = event.target.closest("[role=gridcell]")
    if (!cell) return

    if (event.target === cell) {
      if (cell.getAttribute("aria-selected") !== "true" && selectable(cell)) this.focusCell(cell)
    } else if (!editing(cell)) {
      this.beginEditing(cell)
    }
  }

  // An editor the app removes is not the user leaving. The blur fires while
  // the editor is still attached, so the call is settled a microtask later.
  blurred(event) {
    const cell = this.editingByFocus
    if (!cell || cell.contains(event.relatedTarget)) return

    const { target, relatedTarget } = event
    this.endEditing(cell)
    queueMicrotask(() => {
      if (target.isConnected) this.report("leave", { cell, to: relatedTarget })
    })
  }

  activate(event) {
    const cell = event.target.closest(SELECTABLE)
    if (cell && !editing(cell)) this.report("activate", { cell, via: "dblclick" })
  }

  navigate(event) {
    const cell = event.target.closest("[role=gridcell]")
    if (!cell) return

    if (editing(cell)) {
      if (event.key === "Enter" && !event.shiftKey) this.report("commit", { cell })
      else if (event.key === "Escape") this.report("cancel", { cell })
      else return

      event.preventDefault()
      return
    }

    if (!selectable(cell)) return

    if (event.key === "Enter" || event.key === "F2") {
      event.preventDefault()
      this.report("activate", { cell, via: event.key === "Enter" ? "enter" : "f2" })
      return
    }

    const direction = DIRECTIONS[event.key]
    if (direction) {
      event.preventDefault()
      this.move(direction, { edge: event.ctrlKey, from: cell })
      return
    }

    if (event.key.length === 1 || event.key === "Delete" || event.key === "Backspace") {
      event.preventDefault()
      this.report("activate", { cell, via: "key", key: event.key })
    }
  }

  report(name, detail) {
    const editor = this.editorValue && this.application.getControllerForElementAndIdentifier(this.element, this.editorValue)
    editor?.[name]?.(detail)
    return this.dispatch(name, { prefix: PREFIX, cancelable: true, detail })
  }

  // `direction` is up, down, left, right, home or end; `edge` takes home and
  // end to the grid's corners.
  move(direction, { edge = false, from = this.selected } = {}) {
    if (!from) return

    const rows = this.rows
    const row = from.parentElement
    const r = rows.indexOf(row)
    const c = [...row.children].indexOf(from)
    const inColumn = (candidates) => candidates.map((other) => other.children[c]).find(selectable)
    const moves = {
      up: () => inColumn(rows.slice(0, r).reverse()),
      down: () => inColumn(rows.slice(r + 1)),
      left: () => [...row.children].slice(0, c).reverse().find(selectable),
      right: () => [...row.children].slice(c + 1).find(selectable),
      home: () => (edge ? this.cells[0] : [...row.children].find(selectable)),
      end: () => (edge ? this.cells.at(-1) : [...row.children].findLast(selectable)),
    }
    this.focusCell(moves[direction]?.())
  }

  focusCell(cell) {
    if (!cell) return

    const from = this.selected
    from?.removeAttribute("aria-selected")
    cell.setAttribute("aria-selected", "true")
    this.lastSelected = cell
    this.position = { row: this.rows.indexOf(cell.parentElement), column: [...cell.parentElement.children].indexOf(cell) }
    cell.focus({ preventScroll: true })
    this.reveal(cell)
    if (from !== cell) this.report("select", { from, to: cell, row: cell.parentElement, column: this.position.column })
  }

  beginEditing(cell) {
    cell.dataset.mode = "editing"
    cell.querySelector("[data-slot=tooltip]")?.setAttribute(TOOLTIP_ENABLED, "false")
    this.editingByFocus = cell
    if (this.selected !== cell && selectable(cell)) {
      const from = this.selected
      from?.removeAttribute("aria-selected")
      cell.setAttribute("aria-selected", "true")
      this.lastSelected = cell
      this.report("select", { from, to: cell, row: cell.parentElement, column: [...cell.parentElement.children].indexOf(cell) })
    }
  }

  endEditing(cell) {
    delete cell.dataset.mode
    cell.querySelector("[data-slot=tooltip]")?.removeAttribute(TOOLTIP_ENABLED)
    this.editingByFocus = null
  }

  // The selected cell's row was replaced or removed: the cell now at that
  // position takes over, as long as focus was in the grid or nowhere.
  reselect() {
    const gone = this.lastSelected
    if (!gone || this.grid.contains(gone)) return

    const rows = this.rows
    const row = rows[Math.min(this.position.row, rows.length - 1)]
    const cell = row && (row.children[this.position.column] ?? row.lastElementChild)
    const focusFree = document.activeElement === document.body || this.element.contains(document.activeElement)
    if (cell && selectable(cell) && focusFree) this.focusCell(cell)
    else this.lastSelected = null
  }

  // Nearest edge first, then out from under pinned siblings, which cover it.
  reveal(cell) {
    cell.scrollIntoView({ block: "nearest", inline: "nearest" })
    const box = cell.getBoundingClientRect()
    for (const pinned of cell.parentElement.children) {
      if (pinned === cell || getComputedStyle(pinned).position !== "sticky") continue

      const edge = pinned.getBoundingClientRect()
      const before = pinned.compareDocumentPosition(cell) & Node.DOCUMENT_POSITION_FOLLOWING
      if (before && edge.right > box.left) this.scroller.scrollLeft -= edge.right - box.left
      if (!before && edge.left < box.right) this.scroller.scrollLeft += box.right - edge.left
    }
  }

  get grids() {
    return [this.hasHeaderTarget && this.headerTarget, this.hasFooterTarget && this.footerTarget].filter(Boolean)
  }

  get grid() {
    return this.element.querySelector("[role=grid], [role=table]")
  }

  get rows() {
    return [...this.grid.querySelectorAll("[data-slot=data-grid-body] > [role=row]")]
  }

  get cells() {
    return [...this.grid.querySelectorAll(SELECTABLE)]
  }

  get selected() {
    return this.grid.querySelector("[role=gridcell][aria-selected]")
  }

  get editing() {
    return this.grid.querySelector("[role=gridcell][data-mode=editing]")
  }

  get scroller() {
    return this.hasBodyTarget ? this.bodyTarget : this.element
  }
}

const PREFIX = "data-grid"

const ROW = "[data-slot=data-grid-body] > [role=row]"

const SELECTABLE = "[role=gridcell]:not([data-selectable=false])"

const TOOLTIP_ENABLED = "data-shadcnrb--anchored--component-enabled-value"

const DIRECTIONS = { ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right", Home: "home", End: "end" }

const selectable = (cell) => cell?.matches(SELECTABLE)

const editing = (cell) => cell.dataset.mode === "editing"

const tracks = (grid) => getComputedStyle(grid).gridTemplateColumns.split(" ").map(parseFloat)
