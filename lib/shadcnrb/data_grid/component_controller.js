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
// skipped.
export default class extends Controller {
  static targets = ["header", "body", "footer"]

  connect() {
    this.rowObserver = new MutationObserver((mutations) => this.rowsAdded(mutations))
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

  rowsAdded(mutations) {
    const rows = mutations.flatMap(({ addedNodes }) => [...addedNodes])
      .filter((node) => node.nodeType === Node.ELEMENT_NODE)
      .flatMap((node) => (node.matches(ROW) ? [node] : [...node.querySelectorAll(ROW)]))
    if (rows.length === 0) return

    rows.forEach((row) => this.stamp(row))
    if (this.hasBodyTarget) this.align()
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
      if (head.dataset.truncate && !cell.title) cell.title = cell.textContent.trim()
      if (!selectable) return

      cell.setAttribute("role", "gridcell")
      if (cell.dataset.selectable === "false") cell.classList.remove(...selectable)
      else cell.tabIndex = -1
    })
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
    if (cell) this.focusCell(cell)
  }

  // The grid is the tab stop and hands focus on to the selected cell.
  enter(event) {
    if (event.target === this.grid) this.focusCell(this.selected ?? this.cells[0])
  }

  navigate(event) {
    const cell = event.target.closest(SELECTABLE)
    if (!cell) return

    const rows = this.rows
    const row = cell.parentElement
    const r = rows.indexOf(row)
    const c = [...row.children].indexOf(cell)
    const inColumn = (candidates) => candidates.map((other) => other.children[c]).find(selectable)
    const moves = {
      ArrowUp: () => inColumn(rows.slice(0, r).reverse()),
      ArrowDown: () => inColumn(rows.slice(r + 1)),
      ArrowLeft: () => [...row.children].slice(0, c).reverse().find(selectable),
      ArrowRight: () => [...row.children].slice(c + 1).find(selectable),
      Home: () => (event.ctrlKey ? this.cells[0] : [...row.children].find(selectable)),
      End: () => (event.ctrlKey ? this.cells.at(-1) : [...row.children].findLast(selectable)),
    }
    const target = moves[event.key]?.()
    if (!target) return

    event.preventDefault()
    this.focusCell(target)
  }

  focusCell(cell) {
    if (!cell) return

    this.selected?.removeAttribute("aria-selected")
    cell.setAttribute("aria-selected", "true")
    cell.focus({ preventScroll: true })
    this.reveal(cell)
    this.dispatch("select", { detail: { row: cell.parentElement, cell } })
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

  get scroller() {
    return this.hasBodyTarget ? this.bodyTarget : this.element
  }
}

const ROW = "[data-slot=data-grid-body] > [role=row]"

const SELECTABLE = "[role=gridcell]:not([data-selectable=false])"

const selectable = (cell) => cell?.matches(SELECTABLE)

const tracks = (grid) => getComputedStyle(grid).gridTemplateColumns.split(" ").map(parseFloat)
