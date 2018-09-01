###expected
initial->s1_1->s1_3->s1_2->s1_4->s1_5->s1_2;
s1_3->s1_8;
s1_4->s1_7->s1_2;
s1_5->s1_6->s1_7->s1_8;
s1_5->s1_8->final;
###
for a in [0]
  if b
    continue
  foo()
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nFor"];
s1_3[label="ArrayExpression\nLiteral (0)\nLiteral:exit (0)\nArrayExpression:exit"];
s1_2[label="Identifier (a)\nIdentifier:exit (a)"];
s1_4[label="BlockStatement\nIfStatement\nIdentifier (b)\nIdentifier:exit (b)"];
s1_5[label="BlockStatement\nContinueStatement\nContinueStatement:exit"];
s1_8[label="For:exit\nProgram:exit"];
s1_7[label="ExpressionStatement\nCallExpression\nIdentifier (foo)\nIfStatement:exit\nIdentifier:exit (foo)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit"];
s1_6[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nBlockStatement:exit"];
initial->s1_1->s1_3->s1_2->s1_4->s1_5->s1_2;
s1_3->s1_8;
s1_4->s1_7->s1_2;
s1_5->s1_6->s1_7->s1_8;
s1_5->s1_8->final;
}
###
