# What the patch changes

Everything below is a change to **Butterscotch** (the open-source runner), applied on top of commit
[`0a36f37`](https://github.com/ButterscotchRunner/Butterscotch/commit/0a36f376270087a229bf268591582af4760607fe).
GameMaker itself and the games' files are **not** modified. These are fixes to the way Butterscotch imitates
GameMaker, so that games behave the way they do on the original Windows runner.

Most fixes matter for **GameMaker: Studio 1.4** games, but none of them are specific to one game.

## Engine accuracy (behaves like real GameMaker)

- **`argument[N]` assignment:** assigning to `argument[N]` turned the argument into an array, which caused infinite loops.
- **Bitwise operators:** `& | ^ << >> ~` were 32-bit; GameMaker uses 64-bit integers.
- **Logical NOT:** `!` used "== 0" instead of GameMaker's truthiness, so `!-1` is now true, as in GameMaker.
- **`ds_list_find_index`:** treated `37` and `37.0` as different values. GameMaker compares numbers by value.
- **`ds_list_set`:** rejected every 3-argument call.
- **Same-depth draw order:** objects at the same depth were drawn in GameMaker 2 order. GameMaker 1.x draws the newer instance behind, and 1.x games now use the 1.x order.
- **Room tiles:** tiles added or moved while running (`tile_add`, `tile_layer_shift`, …) stayed in a non-persistent room forever. Like GameMaker, a room now starts from its original tiles each time you enter it.
- **`tile_layer_shift`:** didn't move the tiles.
- **`tile_set_visible`:** did nothing for GameMaker 1.x tiles. Tiles a game hides (for example secret blocks in dark rooms) were still drawn.
- **`ds_map_destroy` / `ds_list_destroy`:** didn't destroy nested maps and lists that came from `json_decode` or `ds_map_add_map` / `ds_map_add_list`. GameMaker destroys them together with the parent. This leaked memory every time a game loaded a JSON file (some games do it on every room change).
- **`ds_grid_create` / `ds_grid_resize`:** new cells were `undefined`. GameMaker fills them with `0`, and games that check for `0` (for example to find the end of a list) showed the word "undefined" instead.
- **`ds_grid_read` / `ds_grid_write`:** used the wrong cell order for GameMaker: Studio 1.x grids (magic 602, column-major).
- **`background_get_name` / `background_exists`:** read the sprite list on GameMaker: Studio 1.x.
- **`background_showcolour`** (GM:S 1.x) was ignored.
- **`audio_get_name`:** didn't accept sound instance ids.
- **Audio groups:** groups loaded out of order were stored at the wrong index, so there was no music.
- **Surfaces:** surface id 0 was treated as a live surface (some "create the surface if it doesn't exist" checks never ran), and freed surface ids leaked.
- **Shaders:** samplers could share texture unit 1 with the base texture.
- **Saving:** writes to `working_directory` went to the read-only game bundle. They now go to the save folder.
- **About 30 functions that were missing** are now implemented, including `tile_get_*`, `tile_set_scale`, `room_tile_clear`, `room_set_view*`, `ds_grid_clear`, `ds_grid_set_region`, `ds_*_set_post`, `background_assign`, `audio_group_stop_all`, `script_exists`, `script_get_name`, `filename_ext` and `random_get_seed`.
- **`audio_sound_length`** was wrong for compressed (OGG) sounds with the OpenAL audio backend used on Switch. Games that wait for a sound to finish ended those waits early.

## Optional: `BS_EXACT_POINTS`

A build option (`EXACT_POINTS=yes` in `settings.txt`). It makes `draw_point` / `draw_point_colour` land exactly on (x, y), like the original Windows runner, instead of using the usual 1-pixel offset for primitives. Some GM:S 1.4 games build a palette texture pixel by pixel with `draw_point`; without this option their whole palette is shifted by one pixel and every colour is wrong. It's off by default, so other games are unaffected.

## Switch improvements

- **Configurable homebrew-menu metadata:** title, author, version, icon and SD-card save folder (`NX_APP_TITLE`, `NX_APP_AUTHOR`, `NX_APP_VERSION`, `NX_APP_ICON`, `NX_APP_DIR`).
- **Game bundled in the `.nro`:** the game's files are packed into romfs, so you get one file to copy.
- **Audio decoded on first use** instead of loading every audio group into RAM at boot. Large soundtracks otherwise exceed the homebrew memory budget and slow startup a lot.
- **Long music is streamed** (OpenAL backend) instead of being fully decoded when it starts, which removes a short freeze when a new song begins. Seeking works on streamed music.
- **Faster boot:** the CPU runs at full speed (1785 MHz boost mode, like official games on loading screens) while the game loads. It returns to normal clocks once the game runs at full speed (after 20 seconds at most).
- **ZL and ZR work as buttons:** they were only reported as analog trigger values, never as "pressed".

## Speed

- Faster `json_decode` string parsing, `file_text_read_string` and the hex decoding used by `ds_*_read` (about 27% less work at boot in the tested game).
- `ds_list_create` no longer rescans every list in use when looking for a free slot.
- `string_copy` reads its string argument in place instead of copying the whole string first. Games that cut small pieces out of one long string many times per frame run much faster.
- `sprite_create_from_surface` copies the surface on the GPU instead of reading it back to the CPU (`glReadPixels`), which made the CPU wait for the GPU. Games that rebuild a sprite from a surface every frame (for example a palette that changes colour constantly) no longer slow down on Switch.

## Not changed

- No game's code or data is modified.
- Upstream Butterscotch features and other platforms are untouched; most changes only take effect for GameMaker: Studio 1.x games or on Switch.
