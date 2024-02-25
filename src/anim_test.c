#include "core.h"
#include "audio/sound.h"
#include "graphics/render.h"

void RenderTest(u32* param)
{
    InitAnim(0);
    REG_BG2PA = 0x100;

    struct RenderContext* context = (struct RenderContext*) gPtrs[PTR_RENDER_CONTEXT];
    u8* buffer = context->buffer;

    LoadVFXFile(209, buffer, true, true);

    struct Texture texture = {
        .width  = 6, // 64px
        .height = 6, // 64px
        .gfx    = buffer
    };
    struct Draw3DCommand* cmds = Draw3D_CreateCommandArray(1);
    cmds[0].cmd     = DRAW3D_TRIS_TEX_ADD;
    cmds[0].param   = DRAW3D_CULL_NONE;
    cmds[0].vertices   = (fx32*)(buffer + 0x1000);
    cmds[0].triangles    = MDL_Quad_TrianglesUV64;
    cmds[0].texture = &texture;
    cmds[0]._unk14  = 0;
    cmds[0]._unk18  = 0;
    cmds[0]._unk19  = 0;

    context->blitMode  = BLIT_FADE;
    context->blitParam = 0;
    CreateTask(VFXBlitTask, 0xC80);

    PlaySound(190);

    u16 i = 0;
    u16 scale = 0;
    while (true) {

        if (gKeyPress & KEY_L) break;

        LoadIdentityMatrix();

        if (scale <= 0x16) scale++;
        MatrixScale(scale << 11);

        MatrixRoll(i << 6);
        MatrixYaw(i << 10);
        MatrixPitch(i << 7);
        ProjectVertices(MDL_Quad_Vertices, (fx32*)(buffer + 0x1000), 4);
        Draw3D(cmds);
        i += 1;

        context->dirty = true;
        WaitFrames(1);
    }

    DestroyTask(VFXBlitTask);
    Free(cmds);
    EndAnim();
}