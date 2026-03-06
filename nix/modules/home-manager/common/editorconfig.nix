{ ... }:
{
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
        max_line_length = 0;
      };

      "*.{js,ts,jsx,tsx,ts,py,css,scss}" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 2;
        indent_style = "tab";
        insert_final_newline = true;
        max_line_length = 80;
        quote_type = "single";
      };

      "*.{res,resi}" = {
        indent_style = "tab";
        indent_size = 2;
        max_line_length = 0;
      };

      "{package.json,*.yml}" = {
        indent_style = "space";
      };

      "*.md" = {
        indent_style = "space";
        indent_size = 2;
        max_line_length = 80;
      };
    };
  };
}
