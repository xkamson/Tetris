
package body output is
    task body Screen is
        package Int_IO is new Ada.Text_IO.Integer_IO (Num => Integer);  

        procedure clear_p is
        begin
            Put(ASCII.ESC & "[2J"); 
        end clear_p;

        procedure move_p(to : Position) is
        begin
            New_Line;
            Put(ASCII.ESC & "[");
            Int_IO.Put(to.Y,1);
            Put(";");
            Int_IO.Put(to.X,1);
            Put("H");
        end move_p;

        procedure putString_p(str : String) is
        begin
            Ada.Text_IO.Put(str);
        end putString_p;

        procedure draw_p(pos : Position; str : String) is
        begin
            move_p(pos);
            putString_p(str);
        end draw_p;

        procedure writeInstruction(startPos : Position) is
        begin
            Colors.yellow;
            draw_p(startPos, " <-   rotate left  rotate right   ->");
            draw_p((x => startPos.x, y => startPos.y+1), 
                             " a         q            e          d");
            Colors.white;
        end writeInstruction;

        procedure writeFrame_p(width : Integer; height : Integer; pos : out Position; previewPos : out Position) is
        begin
            Colors.light_blue;
            for i in 1..(height-1) loop
                move_p((X => 1, Y => i)); Put("#");
                move_p((X => width, Y => i)); Put("#");
            end loop;
            New_Line;
            for i in 1..width loop
                Put("#");
            end loop;

            for i in 1..15 loop
                for j in 1..height loop
                    if i > 2 and i < 13 and j > 6 and j < height-2 then
                        draw_p((X => width+i, Y => j)," ");
                    else
                        draw_p((X => width+i, Y => j),"#");
                    end if;
                end loop;
            end loop;

            writeInstruction((x=>1, y => height+2));
            Colors.yellow;
            draw_p((x => width + 16, y => 3),"  quit"); 
            draw_p((x => width + 16, y => 4),"   Q");
            draw_p((x => width + 16, y => 6),"  reset");
            draw_p((x => width + 16, y => 7),"    R");
            draw_p((x => width + 16, y => 9),"  speed");
            draw_p((x => width + 16, y => 10),"   s");

            previewPos.x := width+4;
            previewPos.y := 7;

            Colors.light_green;
            draw_p((x=>width+2, y=>3)," Score:     ");
            pos.x := width + 10;
            pos.y := 3;
            Colors.white;
        end writeFrame_p;

        procedure displayGameOverMsg_p is
        width : Integer := 30   ;
        height : Integer := 9;
        begin
            Colors.light_blue;
            clear_p;
            move_p((x=>1,y=>1));
            for i in 1..width loop
                Put("*");
            end loop;
            for i in 1..height loop
                move_p((X => 1, Y => i)); Put("*");
                move_p((X => width, Y => i)); Put("*");
            end loop;
            move_p((x=>2,y=>height));
            for i in 2..width-1 loop
                Put("*");
            end loop;

            Colors.red;
            move_p((x=>12,y=>2)); putString_p("GAME OVER!");
            move_p((x=>5,y=>4)); putString_p("You have lost the game.");
            Colors.light_red;
            move_p((x=>7,y=>6)); putString_p("quit     play again");
            move_p((x=>7,y=>7)); putString_p(" Q           R");

        end displayGameOverMsg_p;

    doQuit : Boolean := false;
    begin
        loop
            select 
                accept quit do
                    doQuit := true;
                end quit;
            or
                accept clear do
                    clear_p;
                end clear;
            or
                accept move(to : Position) do
                    move_p(to);
                end move;
            or
                accept putString(str : String) do
                    putString_p(str);
                end putString;
            or
                accept draw(pos : Position; str : String) do
                    draw_p(pos, str);
                end draw;
            or
                accept writeFrame(width : Integer; height : Integer; pos : out Position; previewPos : out Position) do
                    writeFrame_p(width, height, pos, previewPos);
                end writeFrame;
            or
                accept displayGameOverMsg do
                    displayGameOverMsg_p;
                end displayGameOverMsg;
            or
                delay until Clock + Duration(1);
            end select;

            if doQuit = true then
                exit;
            end if;
        end loop;
    end Screen;

end output;