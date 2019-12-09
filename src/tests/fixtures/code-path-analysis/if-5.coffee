### eslint-disable ###
###expected
initial->s1_1->s1_2->s1_3->s1_4;
s1_1->s1_4;
s1_2->final;
s1_4->final;
###
return 0 unless a
foo()
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nExpressionStatement\nConditionalExpression\nIdentifier (a)\nIdentifier:exit (a)"];
s1_2[label="ReturnStatement\nLiteral (0)\nLiteral:exit (0)\nReturnStatement:exit"];
s1_3[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\n????"];
s1_4[label="ExpressionStatement\nCallExpression\nIdentifier (foo)\nConditionalExpression:exit\nExpressionStatement:exit\nIdentifier:exit (foo)\nCallExpression:exit\nExpressionStatement:exit\nProgram:exit"];
initial->s1_1->s1_2->s1_3->s1_4;
s1_1->s1_4;
s1_2->final;
s1_4->final;
}
###
