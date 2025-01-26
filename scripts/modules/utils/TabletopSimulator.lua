---@alias DeadObject {}

---@class Object
---@field held_by_color string
---@field type string
---@field getPosition fun():Vector
---@field setPosition fun(position :Vector)
---@field setPositionSmooth fun(position :Vector)
---@field getScale number
---@field setDecals fun(parameters: table)
---@field setRotation fun(vector: Vector)
---@field setRotationSmooth fun(vector: Vector)
---@field flip fun()
---@field setGMNotes fun(notes: string)
---@field getGMNotes fun(): string

---@class Zone: Object
---@field getObjects fun(): Object[]

---@class Bag: Object
---@field getObjects fun(): Object[]
---@field takeObject fun(parameters: table)
---@field getQuantity fun(): integer

---@class Deck: Bag

---@alias DeckOrCard Deck|Card

---@class Card: Object

---@class Button
