/*
    Written by Kyjko (Bognár Miklós)
    CUDA - vector operations on GPU - with SDL
*/

#include <stdio.h>
#include <time.h>
#include <memory.h>
#include <stdlib.h>
#include <SDL.h>

#undef main

#define N 20
#define W 1920
#define H 1080

short quit = 0;

enum Operators {
    ADD,
    SUB,
    MUL
};

typedef struct context {
    SDL_Window* w;
    SDL_Renderer* r;
} context;

__global__ void kernel(enum Operators type, float* a, float* b, float* c, unsigned long n) {
    unsigned long idx = blockDim.x * blockIdx.x + threadIdx.x;
    
    if(idx > n)
        return;
    
        switch(type) {
        case ADD:
            c[idx] = a[idx] + b[idx];
        case SUB:
            c[idx] = a[idx] - b[idx];
        case MUL:
            c[idx] = a[idx] * b[idx];
        default: 
            return;
        
    }
}

__host__ void display_vectors(enum Operators type, float* a, float* b, float* c, unsigned long n) {
    for(int i = 0; i < N; i++) {
        printf("%d. : %f %s %f = %f\n", i, a[i], 
            type == ADD ? "+" : type == SUB ? "-" : type == MUL ? "*" : "?", b[i], c[i]);
    }
}

errno_t init_sdl(context* ctx) {
    if(SDL_Init(SDL_INIT_VIDEO) < 0)
        return -1;
    
    ctx->w = SDL_CreateWindow("Numpu", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, W, H, SDL_WINDOW_SHOWN);
    if(ctx->w == NULL)
        return -2;
    ctx->r = SDL_CreateRenderer(ctx->w, -1, SDL_RENDERER_ACCELERATED);
    if(ctx->r == NULL)
        return -3;
    

    return 0;

}

void render(context* ctx) {
    
}

void eventloop(context* ctx) {
    while(quit != 1) {
        SDL_Event e;
        while(SDL_PollEvent(&e) != NULL) {
            switch(e.type) {
                case SDL_QUIT:
                    quit = 1;
                    break;
            }
        }

        render(ctx);
    }

    SDL_DestroyRenderer(ctx->r);
    SDL_DestroyWindow(ctx->w);
    ctx->w = NULL;
    ctx->r = NULL;
    SDL_Quit();
}

int main(int argc, char** argv) {
    srand((unsigned)time(NULL));
    
    context ctx;
    memset(&ctx, 0, sizeof(ctx));

    //init sdl
    if(init_sdl(&ctx) < 0) {
        perror("cannot initialize SDL!");    
        return -1;
    }

    eventloop(&ctx);

    float* a = (float*)malloc(sizeof(float)*N);
    float* b = (float*)malloc(sizeof(float)*N);
    float* c = (float*)malloc(sizeof(float)*N);

    memset(c, 0.0, sizeof(float)*N);
    
    for(int i = 0; i < N; i++) {
        a[i] = (rand()/(float)RAND_MAX)*100;
        b[i] = (rand()/(float)RAND_MAX)*100;
    }

    float *d_a, *d_b, *d_c;

    cudaMalloc((void**)&d_a, sizeof(float)*N);
    cudaMalloc((void**)&d_b, sizeof(float)*N);
    cudaMalloc((void**)&d_c, sizeof(float)*N);

    cudaMemcpy(d_a, a, sizeof(float)*N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, sizeof(float)*N, cudaMemcpyHostToDevice);
    cudaMemcpy(d_c, c, sizeof(float)*N, cudaMemcpyHostToDevice);

    kernel<<<100, 100>>> (MUL, d_a, d_b, d_c, N);

    cudaMemcpy(a, d_a, sizeof(float)*N, cudaMemcpyDeviceToHost);
    cudaMemcpy(b, d_b, sizeof(float)*N, cudaMemcpyDeviceToHost);
    cudaMemcpy(c, d_c, sizeof(float)*N, cudaMemcpyDeviceToHost);

    display_vectors(MUL, a, b, c, N);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(a);
    free(b);
    free(c);
    a = NULL;
    b = NULL;
    c = NULL;

    return 0;
}
