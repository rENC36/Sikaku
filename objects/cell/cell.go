components {
  id: "cell"
  component: "/objects/cell/cell.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"cell_tile\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 64.0\n"
  "  y: 64.0\n"
  "}\n"
  "size_mode: SIZE_MODE_MANUAL\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/atlas/game.atlas\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "label"
  type: "label"
  data: "size {\n"
  "  x: 64.0\n"
  "  y: 64.0\n"
  "}\n"
  "color {\n"
  "  x: 0.23921569\n"
  "  y: 0.2901961\n"
  "  z: 0.41960785\n"
  "}\n"
  "font: \"/assets/fonts/nunitoBOLD.font\"\n"
  "material: \"/builtins/fonts/font.material\"\n"
  ""
  position {
    z: 1.0
  }
}
