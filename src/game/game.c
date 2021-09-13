#include "utils.h"

#include <raylib.h>

#if defined(PLATFORM_WEB)
    #include <emscripten/emscripten.h>
#endif

static void Update() {
    BeginDrawing();
    ClearBackground(DARKPURPLE);

    int width = GetScreenWidth();
    int height = GetScreenHeight();
    Vector2 scale = GetWindowScaleDPI();

    DrawText(TextFormat("screen size: %d, %d\n", width, height), 0, 0, 32, WHITE);
    DrawText(TextFormat("window scale dpi: %f, %f\n", scale.x, scale.y), 0, 40, 32, WHITE);

    DrawRectangleLines(5, 5, GetScreenWidth() - 10, GetScreenHeight() - 10, WHITE);

    Vector2 mousePosition = GetMousePosition();
    DrawCircle(mousePosition.x, mousePosition.y, 10.0, YELLOW);

    Vector2 touchPosition = GetTouchPosition(0);
    DrawCircle(touchPosition.x, touchPosition.y, 10.0, GREEN);

    EndDrawing();
}

void GameRun() {
    // SetConfigFlags(FLAG_WINDOW_RESIZABLE);
    SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_HIGHDPI);

    InitWindow(1280, 720, "Game");

#if defined(PLATFORM_WEB)
    emscripten_set_main_loop(Update, 60, 1);
#else
    SetTargetFPS(60);       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        Update();
    }
#endif

    CloseWindow();
}

void test_Something() {
    check(true == true);
}
