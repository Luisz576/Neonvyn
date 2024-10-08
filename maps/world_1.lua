return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.11.0",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 30,
  height = 20,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 4,
  nextobjectid = 10,
  properties = {},
  tilesets = {
    {
      name = "Tileset_1",
      firstgid = 1,
      class = "",
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 18,
      image = "../assets/tileset/TopDownHouse_FloorsAndWalls.png",
      imagewidth = 288,
      imageheight = 144,
      objectalignment = "unspecified",
      tilerendersize = "tile",
      fillmode = "stretch",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      wangsets = {},
      tilecount = 162,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 30,
      height = 20,
      id = 1,
      name = "ground",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        40, 40, 40, 40, 39, 40, 40, 40, 40, 58, 58, 58, 58, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40,
        58, 39, 40, 40, 40, 40, 58, 58, 58, 40, 40, 40, 39, 39, 39, 39, 39, 39, 40, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        40, 40, 40, 58, 58, 39, 39, 39, 39, 39, 39, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 39, 39, 39, 39, 39, 39, 40, 57, 57,
        40, 40, 40, 40, 39, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 40, 40, 40, 40, 40, 40, 40, 40, 40,
        58, 58, 58, 58, 57, 57, 58, 58, 58, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        39, 40, 57, 58, 57, 58, 58, 40, 40, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57,
        39, 39, 39, 39, 57, 58, 58, 58, 58, 40, 40, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        57, 57, 57, 57, 57, 58, 40, 57, 58, 58, 58, 40, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 58, 58, 58, 58,
        39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57,
        57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 40, 40, 40, 40, 40, 40, 40, 40, 40,
        39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 58, 58, 39, 39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58,
        57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39,
        39, 39, 40, 40, 39, 57, 57, 39, 40, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57,
        39, 39, 39, 40, 39, 57, 39, 39, 39, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 40, 40, 40, 40, 40, 40, 40, 40, 57, 58,
        39, 57, 39, 39, 39, 39, 39, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 40, 40, 40, 40,
        39, 57, 57, 57, 57, 39, 57, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 58, 58, 58, 58, 58,
        39, 39, 39, 39, 39, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 39, 39, 57, 57,
        57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 39, 39, 39, 39, 39, 39, 39, 39, 39, 57, 57, 57, 57, 58,
        57, 57, 39, 39, 39, 57, 58, 58, 58, 58, 58, 57, 57, 39, 39, 39, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 57, 57, 58,
        57, 58, 57, 57, 57, 39, 39, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 2,
      name = "barriers",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 1,
          width = 448.5,
          height = 15.5,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 2,
          name = "",
          type = "",
          shape = "rectangle",
          x = -0.5,
          y = 16,
          width = 16,
          height = 288.5,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 3,
          name = "",
          type = "",
          shape = "rectangle",
          x = 16,
          y = 304.5,
          width = 449,
          height = 15,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 465,
          y = 16,
          width = 14.5,
          height = 287.5,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "spawns",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 8,
          name = "Spawn",
          type = "",
          shape = "point",
          x = 241,
          y = 167.5,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
