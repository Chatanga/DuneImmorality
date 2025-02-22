---@alias DeadObject {
--- gm_notes: string,
--- guid: string,
--- id: integer,
--- name: string,
--- tags: string[] }

---@class Object
---@field addTag fun(tag: string)
---@field clearButtons fun()
---@field clone fun(): Object
---@field clone fun(parameters: table)
---@field createButton fun(parameters: table): Button
---@field deal fun(dealCardCount: integer, color: string)
---@field destruct fun()
---@field editButton fun(parameters: table)
---@field flip fun()
---@field getButtons fun(): Button[]
---@field getGMNotes fun(): string
---@field getGUID fun(): string
---@field getLock fun(): boolean
---@field getName fun(): string
---@field getPosition fun():Vector
---@field getRotation fun(): Vector
---@field getScale fun(): Vector
---@field getSnapPoints fun(): SnapPoint[]
---@field getStateId integer
---@field getStates fun(): DeadObject[]
---@field getTags fun(): string[]
---@field hasTag fun(tag: string): boolean
---@field held_by_color string
---@field interactable boolean
---@field is_face_down boolean
---@field positionToLocal fun(vector: Vector): Vector
---@field positionToWorld fun(vector: Vector): Vector
---@field removeButton fun(index: integer)
---@field removeTag fun(tag: string)
---@field setColorTint fun(color: string)
---@field setDecals fun(parameters: table)
---@field setGMNotes fun(notes: string)
---@field setInvisibleTo fun(colors: string[])
---@field setLock fun(lock: boolean)
---@field setName fun(name: string)
---@field setPosition fun(position :Vector)
---@field setPositionSmooth fun(position :Vector, collide?: boolean, fast?: boolean)
---@field setRotation fun(vector: Vector)
---@field setRotationSmooth fun(vector: Vector, collide?: boolean, fast?: boolean)
---@field setSnapPoints fun(snapPoints: SnapPoint[])
---@field setState fun(index: integer)
---@field spawning boolean
---@field type string

---@class Zone: Object
---@field getObjects fun(ignoreTags?: boolean): Object[]

---@class Container: Object
---@field Container Container
---@field getObjects fun(): DeadObject[]
---@field getQuantity fun(): integer
---@field search fun(color: string, index: integer)
---@field shuffle fun()
---@field takeObject fun(parameters: table)

---@class Bag: Container

---@class Deck: Container

---@alias DeckOrCard Deck|Card

---@class Card: Object

---@class Player
---@field color PlayerColor
---@field steam_id string
---@field steam_name string

---@class Widget

---@class Button: Widget
---@field click_function string
---@field index integer

---@alias SnapPoint {
--- position: Vector,
--- rotation_snap: boolean,
--- tags: string[] }

---@class Vector
---@field copy fun(self: Vector): Vector
---@field setAt fun(self: Vector, coordinate: string, value: number): nil
---@field x number
---@field y number
---@field z number

---@alias ClickFunction fun(object: Object, color:PlayerColor, altClick:boolean)

---@alias Xml table

---@class Player
---@field changeColor fun(newColor: string)
---@field seated boolean

---@alias GUID string
