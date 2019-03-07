#ifndef MUPDF_EXTENSIONS_H
#define MUPDF_EXTENSIONS_H

#include "mupdf/pdf.h"


#if FZ_ENABLE_PDF
#include "mupdf/pdf.h" /* for pdf output */
#endif

#ifndef DISABLE_MUTHREADS
#include "mupdf/helpers/mu-threads.h"
#endif

/*
 * mudraw -- command line tool for drawing and converting documents
 */

#include "mupdf/fitz.h"


#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/time.h> /* for gettimeofday */
#include <unistd.h>
#include <signal.h>

#ifdef __cplusplus
extern "C" {
#endif















    /* Enable for helpful threading debug */
    /* #define DEBUG_THREADS(A) do { printf A; fflush(stdout); } while (0) */
#define DEBUG_THREADS(A) do { } while (0)

    enum {
        OUT_NONE,
        OUT_PNG, OUT_TGA, OUT_PNM, OUT_PGM, OUT_PPM, OUT_PAM,
        OUT_PBM, OUT_PKM, OUT_PWG, OUT_PCL, OUT_PS,
        OUT_TEXT, OUT_HTML, OUT_STEXT,
        OUT_TRACE, OUT_SVG,
#if FZ_ENABLE_PDF
        OUT_PDF,
#endif
        OUT_GPROOF
    };

    enum { CS_INVALID, CS_UNSET, CS_MONO, CS_GRAY, CS_GRAY_ALPHA, CS_RGB, CS_RGB_ALPHA, CS_CMYK, CS_CMYK_ALPHA };

    typedef struct
    {
        char *suffix;
        int format;
    } suffix_t;

    static const suffix_t suffix_table[] =
    {
        { ".png", OUT_PNG },
        { ".pgm", OUT_PGM },
        { ".ppm", OUT_PPM },
        { ".pnm", OUT_PNM },
        { ".pam", OUT_PAM },
        { ".pbm", OUT_PBM },
        { ".pkm", OUT_PKM },
        { ".svg", OUT_SVG },
        { ".pwg", OUT_PWG },
        { ".pcl", OUT_PCL },
        { ".ps", OUT_PS },
#if FZ_ENABLE_PDF
        { ".pdf", OUT_PDF },
#endif
        { ".tga", OUT_TGA },

        { ".txt", OUT_TEXT },
        { ".text", OUT_TEXT },
        { ".html", OUT_HTML },
        { ".stext", OUT_STEXT },

        { ".trace", OUT_TRACE },
        { ".gproof", OUT_GPROOF },
    };

    typedef struct
    {
        char *name;
        int colorspace;
    } cs_name_t;

    static const cs_name_t cs_name_table[] =
    {
        { "m", CS_MONO },
        { "mono", CS_MONO },
        { "g", CS_GRAY },
        { "gray", CS_GRAY },
        { "grey", CS_GRAY },
        { "ga", CS_GRAY_ALPHA },
        { "grayalpha", CS_GRAY_ALPHA },
        { "greyalpha", CS_GRAY_ALPHA },
        { "rgb", CS_RGB },
        { "rgba", CS_RGB_ALPHA },
        { "rgbalpha", CS_RGB_ALPHA },
        { "cmyk", CS_CMYK },
        { "cmyka", CS_CMYK_ALPHA },
        { "cmykalpha", CS_CMYK_ALPHA },
    };

    typedef struct
    {
        int format;
        int default_cs;
        int permitted_cs[6];
    } format_cs_table_t;

    static const format_cs_table_t format_cs_table[] =
    {
        { OUT_PNG, CS_RGB, { CS_GRAY, CS_GRAY_ALPHA, CS_RGB, CS_RGB_ALPHA } },
        { OUT_PPM, CS_RGB, { CS_GRAY, CS_RGB } },
        { OUT_PNM, CS_GRAY, { CS_GRAY, CS_RGB } },
        { OUT_PAM, CS_RGB_ALPHA, { CS_GRAY, CS_GRAY_ALPHA, CS_RGB, CS_RGB_ALPHA, CS_CMYK, CS_CMYK_ALPHA } },
        { OUT_PGM, CS_GRAY, { CS_GRAY, CS_RGB } },
        { OUT_PBM, CS_MONO, { CS_MONO } },
        { OUT_PKM, CS_CMYK, { CS_CMYK } },
        { OUT_PWG, CS_RGB, { CS_MONO, CS_GRAY, CS_RGB, CS_CMYK } },
        { OUT_PCL, CS_MONO, { CS_MONO, CS_RGB } },
        { OUT_PS, CS_RGB, { CS_GRAY, CS_RGB, CS_CMYK } },
        { OUT_TGA, CS_RGB, { CS_GRAY, CS_GRAY_ALPHA, CS_RGB, CS_RGB_ALPHA } },

        { OUT_TRACE, CS_RGB, { CS_RGB } },
        { OUT_SVG, CS_RGB, { CS_RGB } },
#if FZ_ENABLE_PDF
        { OUT_PDF, CS_RGB, { CS_RGB } },
#endif
        { OUT_GPROOF, CS_RGB, { CS_RGB } },

        { OUT_TEXT, CS_RGB, { CS_RGB } },
        { OUT_HTML, CS_RGB, { CS_RGB } },
        { OUT_STEXT, CS_RGB, { CS_RGB } },
    };


    typedef struct worker_t {
        fz_context *ctx;
        int num;
        int band; /* -1 to shutdown, or band to render */
        fz_display_list *list;
        fz_matrix ctm;
        fz_rect tbounds;
        fz_pixmap *pix;
        fz_bitmap *bit;
        fz_cookie cookie;
#ifndef DISABLE_MUTHREADS
        mu_semaphore start;
        mu_semaphore stop;
        mu_thread thread;
#endif
    } worker_t;

    static fz_document *svg_doc = NULL;
    static fz_context *svg_ctx = NULL;
    static pdf_document *svg_pdf_doc = NULL;
    static char *output = NULL;
    static fz_output *out = NULL;
    static fz_buffer *outBuffer = NULL;

    static int output_pagenum = 0;
    static int output_append = 0;
    static int output_file_per_page = 0;

    static char *format = NULL;
    static int output_format = OUT_NONE;

    static float rotation = 0;
    static float resolution = 72;
    static float force_resolution = 0;
    static int res_specified = 0;
    static int width = 0;
    static int height = 0;
    static int fit = 0;

    static float layout_w = 450;
    static float layout_h = 600;
    static float layout_em = 12;
    static char *layout_css = NULL;
    static int layout_use_doc_css = 1;
    static float min_line_width = 0.0f;

    static int showfeatures = 0;
    static int showtime = 0;
    static size_t memtrace_current = 0;
    static size_t memtrace_peak = 0;
    static size_t memtrace_total = 0;
    static int showmemory = 0;
    static int showmd5 = 0;

#if FZ_ENABLE_PDF
    static pdf_document *pdfout = NULL;
#endif

    static int ignore_errors = 0;
    static int uselist = 1;
    static int alphabits_text = 8;
    static int alphabits_graphics = 8;

    static int out_cs = CS_UNSET;
    static float gamma_value = 1;
    static int invert = 0;
    static int band_height = 0;
    static int lowmemory = 0;

    static int errored = 0;
    static fz_stext_sheet *sheet = NULL;
    static fz_colorspace *colorspace;
    static int alpha;
    static char *filename;
    static const char *incomeFileName;
    static int files = 0;
    static int num_workers = 0;
    static worker_t *workers;

    static const char *layer_config = NULL;

    static struct {
        int active;
        int started;
        fz_context *ctx;
#ifndef DISABLE_MUTHREADS
        mu_thread thread;
        mu_semaphore start;
        mu_semaphore stop;
#endif
        int pagenum;
        char *filename;
        fz_display_list *list;
        fz_page *page;
        int interptime;
    } bgprint;

    static struct {
        int count, total;
        int min, max;
        int mininterp, maxinterp;
        int minpage, maxpage;
        char *minfilename;
        char *maxfilename;
    } timing;

    static int isSvgInit = 0;
    static int timeout = 15;






    typedef enum {
        image_type_unkown = -1,
        image_type_jpg,
        image_type_gif,
        image_type_png,
        image_type_bmp,
    } ImageType;

    typedef struct {
        int w, h, n;
        char *filter;
        char *colorspace;
        fz_buffer *data;
        pdf_obj *maskobj;
    }Xobj_Image;

#define extension_okay 0

    char *new_time_string(fz_context *ctx);

    char *new_unique_string(fz_context *ctx, char *prefix, char *suffix);
    ImageType img_recognize(char *filename);

    pdf_document *pdf_open_document_with_filename(fz_context *ctx, const char *file, char *password);

    pdf_document *pdf_open_document_with_filestream(fz_context * ctx, fz_stream *file, char * password);

    fz_buffer *deflate_buffer_fromdata(fz_context *ctx,char *p, int n);

    int pdf_add_image_with_filestream(fz_context *ctx, fz_stream*file, fz_buffer*imgbf,
                                      int pageno, int x, int y, int w, int h, char *savefile);

    int pdf_add_image_with_document(fz_context *ctx, pdf_document *doc, fz_buffer*imgbf, int pageno, int x, int y, int w, int h);

    int pdf_add_image_with_filename(fz_context *ctx, char *pdffile, char *imgfile, int pageno, int x, int y, int w, int h, char *savefile);

    int pdf_add_imagefile(fz_context *ctx, pdf_document *doc, const char *imgfile, int pageno, int x, int y, int w, int h);

    int   pdf_info_is_unencrypted();
    int   pdf_info_need_password();
    char* pdf_info_dimension(int pageNumber);
    int   pdf_info_dimention_length();
    int   pdf_draw_main(int argc, char **argv);
    int   pdf_draw_open(const char *filePath,const char *password, int res, int timeout);
    int   pdf_draw_close();
    int   pdf_draw_close_with_save(const char* path);
    char* pdf_draw_svg_get(int pageNumber,const char *filePath, int res);
    int   pdf_draw_png_get(int pageNumber,const char *filePath, int res);
    int   pdf_draw_png_add_full(const char *imgfile, int pageNumber, int x, int y, int width, int height);
    int   pdf_draw_svg_get_length();
    int   pdf_draw_png_get_length();
    int   pdf_draw_get_total_pages();
    void  closeHandle(int sig);
    //    int mudraw_main(int argc, char **argv);

    // #define redirect_error_output
#ifdef redirect_error_output
    void stderr_tofile(char *filename);
    void stderr_restore();
#endif

    void z_pdf_incremental_save_document(fz_context *ctx, pdf_document *doc, const char *savefile, const char *orignalfile);

    void z_pdf_obj_display(fz_context *ctx, pdf_obj *obj);
#ifdef __cplusplus
}
#endif
#endif
