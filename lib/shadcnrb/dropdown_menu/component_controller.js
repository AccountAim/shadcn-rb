import AnchoredController from "controllers/shadcnrb/anchored/component_controller"

// Identifier: shadcnrb--dropdown-menu--component
//
// Menu semantics on top of the shared anchored engine (which owns panel
// placement, top-layer display, flip/shift, and scroll tracking): click
// toggle, outside-click and Esc dismiss, and cascading sub-menus. Each sub
// nests its own controller instance; open/cancelClose walk up the ancestor
// chain so the whole stack stays visible while a sub is active, `closeAll`
// walks up so picking an item inside a sub also closes the outer menus, and
// closing a menu dismisses its descendants (their panels are independent
// top-layer elements — they would outlive a hidden parent otherwise).
export default class extends AnchoredController {
  static dismissOnOutsideClick = true

  // Bound on the root so the trigger slot's markup stays untouched; clicks
  // that land inside a panel (items, sub rows) don't count as the trigger.
  // For composite triggers (split buttons), mark the toggling element
  // data-slot="dropdown-menu-trigger" — then only it toggles.
  toggle(event) {
    if (event) {
      if (this.contentTargets.some(panel => panel.contains(event.target))) return
      const marked = [...this.element.querySelectorAll('[data-slot="dropdown-menu-trigger"]')]
        .filter(el => !this.contentTargets.some(panel => panel.contains(el)))
      if (marked.length && !marked.some(el => el.contains(event.target))) return
    }
    clearTimeout(this.timer)
    this.openValue = !this.openValue
  }

  // Hover-open for sub-menus: also cancel every ancestor's pending close.
  open() {
    super.open()
    this.parentMenu()?.cancelClose()
  }

  cancelClose() {
    clearTimeout(this.timer)
    this.parentMenu()?.cancelClose()
  }

  closeAll() {
    this.dismiss()
    this.parentMenu()?.closeAll()
  }

  openValueChanged() {
    this.sync()
    if (!this.openValue) this.childMenus().forEach(menu => menu.dismiss())
  }

  parentMenu() {
    const el = this.element.parentElement
      ?.closest('[data-controller~="shadcnrb--dropdown-menu--component"]')
    return el && this.application.getControllerForElementAndIdentifier(
      el, "shadcnrb--dropdown-menu--component")
  }

  childMenus() {
    return [...this.element.querySelectorAll('[data-controller~="shadcnrb--dropdown-menu--component"]')]
      .map(el => this.application.getControllerForElementAndIdentifier(
        el, "shadcnrb--dropdown-menu--component"))
      .filter(Boolean)
  }
}
