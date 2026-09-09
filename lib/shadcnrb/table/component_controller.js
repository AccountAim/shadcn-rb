import { Controller } from "@hotwired/stimulus"

// Identifier: shadcnrb--table--component
// A fixed-header table is two tables: the header outside the scrolling body. This keeps their
// column widths and horizontal scroll in step as rows load or the container resizes; a column
// is as wide as the wider of its heading and its values.
export default class extends Controller {
  static targets = ["header", "body"]

  connect() {
    this.observer = new ResizeObserver(() => this.align())
    this.observer.observe(this.table)
  }

  disconnect() {
    this.observer.disconnect()
  }

  // Measures against the first row with one cell per heading; a colspan
  // placeholder ("Loading…") would hand its full width to the first heading.
  // With no such row the header keeps its natural layout.
  align() {
    const header = this.headerTarget.querySelector("table")
    const heads = Array.from(this.headerTarget.querySelectorAll("th"))
    const row = Array.from(this.table.querySelectorAll("tbody tr")).find(
      (candidate) => candidate.cells.length === heads.length,
    )
    header.style.width = row ? "max-content" : ""
    heads.forEach((head) => (head.style.width = ""))
    if (!row) return

    Array.from(row.cells).forEach((cell, index) => {
      cell.style.minWidth = `${heads[index].getBoundingClientRect().width}px`
    })
    heads.forEach((head, index) => {
      head.style.width = `${row.cells[index].getBoundingClientRect().width}px`
    })
    header.style.width = `${this.table.offsetWidth}px`
  }

  pan() {
    this.headerTarget.scrollLeft = this.bodyTarget.scrollLeft
  }

  get table() {
    return this.bodyTarget.querySelector("table")
  }
}
