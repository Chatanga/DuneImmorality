---@alias DeadObject {
--- id: integer,
--- guid: string,
--- name: string,
--- gm_notes: string,
--- tags: string[] }

---@class Object
---@field type string
---@field interactable boolean
---@field held_by_color string
---@field getPosition fun():Vector
---@field setPosition fun(position :Vector)
---@field setPositionSmooth fun(position :Vector, collide?: boolean, fast?: boolean)
---@field getScale fun(): Vector
---@field setDecals fun(parameters: table)
---@field setRotation fun(vector: Vector)
---@field getRotation fun(): Vector
---@field setRotationSmooth fun(vector: Vector, collide?: boolean, fast?: boolean)
---@field flip fun()
---@field setGMNotes fun(notes: string)
---@field getGMNotes fun(): string
---@field positionToLocal fun(vector: Vector): Vector
---@field positionToWorld fun(vector: Vector): Vector
---@field getSnapPoints fun(): SnapPoint[]
---@field setSnapPoints fun(snapPoints: SnapPoint[])
---@field getButtons fun(): Button[]
---@field clearButtons fun()
---@field removeButton fun(index: integer)
---@field hasTag fun(tag: string): boolean
---@field setLock fun(lock: boolean)
---@field clone fun(parameters: table)
---@field getGUID fun(): string
---@field spawning boolean
---@field destruct fun()
---@field deal fun(dealCardCount: integer, color: string)
---@field getName fun(): string
---@field setInvisibleTo fun(colors: string[])
---@field getStateId integer
---@field getStates fun(): DeadObject[]
---@field setState fun(index: integer)
---@field clone fun(): Object
---@field createButton fun(parameters: table): Button
---@field addTag fun(tag: string)
---@field getTags fun(): string[]
---@field removeTag fun(tag: string)
---@field setColorTint fun(color: string)
---@field editButton fun(parameters: table)
---@field getLock fun(): boolean

---@class Zone: Object
---@field getObjects fun(): Object[]

---@class Container: Object
---@field Container Container -- TODO Clarify
---@field search fun(color: string, index: integer)
---@field getObjects fun(): DeadObject[]
---@field takeObject fun(parameters: table)
---@field getQuantity fun(): integer
---@field shuffle fun()

---@class Bag: Container

---@class Deck: Container

---@alias DeckOrCard Deck|Card

---@class Card: Object

---@class Player
---@field steam_id string
---@field steam_name string
---@field color PlayerColor

---@class Widget

---@class Button: Widget
---@field click_function string
---@field index integer

---@alias SnapPoint {
--- position: Vector,
--- rotation_snap: boolean,
--- tags: string[] }

---@class Vector
---@field x number
---@field y number
---@field z number
---@field copy fun(self: Vector): Vector
---@field setAt fun(self: Vector, coordinate: string, value: number): nil

---@alias ClickFunction fun(object: Object, color:PlayerColor, altClick:boolean)

---@alias Xml table

---@class Player
---@field seated boolean
---@field changeColor fun(newColor: string)

---@alias GUID string
