###expected
initial->s1_1->s1_3->s1_2->s1_4->s1_2;
s1_3->s1_5;
s1_4->s1_5->final;
###
for a in []
  ;
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nFor"];
s1_3[label="ArrayExpression\nArrayExpression:exit"];
s1_2[label="Identifier (a)\nIdentifier:exit (a)"];
s1_4[label="BlockStatement\nBlockStatement:exit"];
s1_5[label="For:exit\nProgram:exit"];
initial->s1_1->s1_3->s1_2->s1_4->s1_2;
s1_3->s1_5;
s1_4->s1_5->final;
}
###
