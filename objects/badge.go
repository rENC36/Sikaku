embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"badge_circle\"\n"
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
  "  x: 128.0\n"
  "  y: 32.0\n"
  "}\n"
  "font: \"/assets/fonts/nunitoBOLD.font\"\n"
  "material: \"/builtins/fonts/font.material\"\n"
  ""
  position {
    y: -15.0
  }
}
