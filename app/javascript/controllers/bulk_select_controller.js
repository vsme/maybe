import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="bulk-select"
export default class extends Controller {
  static targets = ["row", "group", "selectionBar", "selectionBarText", "bulkEditDrawerTitle"]
  static values = {
    resource: String,
    selectedIds: {type: Array, default: []}
  }

  connect() {
    document.addEventListener("turbo:load", this.#updateView)

    this.#updateView()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.#updateView)
  }

  bulkEditDrawerTitleTargetConnected(element) {
    element.innerText = `Edit ${this.selectedIdsValue.length} ${this.#pluralizedResourceName()}`
  }

  submitBulkRequest(e) {
    const form = e.target.closest("form");
    const scope = e.params.scope
    this.#addHiddenFormInputsForSelectedIds(form, `${scope}[entry_ids][]`, this.selectedIdsValue)
    form.requestSubmit()
  }

  togglePageSelection(e) {
    if (e.target.checked) {
      this.#selectAll()
    } else {
      this.deselectAll()
    }
  }

  toggleGroupSelection(e) {
    const group = this.groupTargets.find(group => group.contains(e.target))

    this.#rowsForGroup(group).forEach(row => {
      if (e.target.checked) {
        this.#addToSelection(row.dataset.id)
      } else {
        this.#removeFromSelection(row.dataset.id)
      }
    })
  }

  toggleRowSelection(e) {
    if (e.target.checked) {
      this.#addToSelection(e.target.dataset.id)
    } else {
      this.#removeFromSelection(e.target.dataset.id)
    }
  }

  deselectAll() {
    this.selectedIdsValue = []
  }

  selectedIdsValueChanged() {
    this.#updateView()
  }

  #addHiddenFormInputsForSelectedIds(form, paramName, transactionIds) {
    this.#resetFormInputs(form, paramName);

    transactionIds.forEach(id => {
      const input = document.createElement("input");
      input.type = 'hidden'
      input.name = paramName
      input.value = id
      form.appendChild(input)
    })
  }

  #resetFormInputs(form, paramName) {
    const existingInputs = form.querySelectorAll(`input[name='${paramName}']`);
    existingInputs.forEach((input) => input.remove());
  }

  #rowsForGroup(group) {
    return this.rowTargets.filter(row => group.contains(row))
  }

  #addToSelection(idToAdd) {
    this.selectedIdsValue = Array.from(
      new Set([...this.selectedIdsValue, idToAdd])
    )
  }

  #removeFromSelection(idToRemove) {
    this.selectedIdsValue = this.selectedIdsValue.filter(id => id !== idToRemove)
  }

  #selectAll() {
    this.selectedIdsValue = this.rowTargets.map(t => t.dataset.id)
  }

  #updateView = () => {
    this.#updateSelectionBar()
    this.#updateGroups()
    this.#updateRows()
  }

  #updateSelectionBar() {
    const count = this.selectedIdsValue.length
    this.selectionBarTextTarget.innerText = `${count} ${this.#pluralizedResourceName()} selected`
    this.selectionBarTarget.hidden = count === 0
    this.selectionBarTarget.querySelector("input[type='checkbox']").checked = count > 0
  }

  #pluralizedResourceName() {
    return `${this.resourceValue}${this.selectedIdsValue.length === 1 ? "" : "s"}`
  }

  #updateGroups() {
    this.groupTargets.forEach(group => {
      const rows = this.rowTargets.filter(row => group.contains(row))
      const groupSelected = rows.length > 0 && rows.every(row => this.selectedIdsValue.includes(row.dataset.id))
      group.querySelector("input[type='checkbox']").checked = groupSelected
    })
  }

  #updateRows() {
    this.rowTargets.forEach(row => {
      row.checked = this.selectedIdsValue.includes(row.dataset.id)
    })
  }
}
