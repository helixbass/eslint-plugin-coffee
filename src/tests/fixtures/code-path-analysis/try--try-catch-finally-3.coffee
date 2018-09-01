###expected
initial->s1_1->s1_3->s1_4->s1_7->s1_8->s1_10;
s1_1->s1_5->s1_6->s1_7;
s1_3->s1_11;
s1_7->s1_10;
s1_8->s1_11;
s1_1->s1_8;
s1_5->s1_8;
s1_11->final;
s1_10->final;
###
try
  if a
    return
  else
    throw 0
catch err
  b()
finally
  c()

last()
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nTryStatement\nBlockStatement\nIfStatement\nIdentifier (a)\nIdentifier:exit (a)"];
s1_3[label="BlockStatement\nReturnStatement\nReturnStatement:exit"];
s1_4[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nBlockStatement:exit"];
s1_7[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nIfStatement:exit\nBlockStatement:exit"];
s1_8[label="CatchClause\nIdentifier (err)\nBlockStatement\nExpressionStatement\nCallExpression\nIdentifier (b)\nIdentifier:exit (err)\nIdentifier:exit (b)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit\nCatchClause:exit"];
s1_10[label="BlockStatement\nExpressionStatement\nCallExpression\nIdentifier (c)\nExpressionStatement\nCallExpression\nIdentifier (last)\nIdentifier:exit (c)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit\nTryStatement:exit\nIdentifier:exit (last)\nCallExpression:exit\nExpressionStatement:exit\nProgram:exit"];
s1_5[label="BlockStatement\nThrowStatement\nLiteral (0)\nLiteral:exit (0)\nThrowStatement:exit"];
s1_6[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nBlockStatement:exit"];
s1_11[label="BlockStatement\nExpressionStatement\nCallExpression\nIdentifier (c)\nIdentifier:exit (c)\nCallExpression:exit\nExpressionStatement:exit\nBlockStatement:exit"];
initial->s1_1->s1_3->s1_4->s1_7->s1_8->s1_10;
s1_1->s1_5->s1_6->s1_7;
s1_3->s1_11;
s1_7->s1_10;
s1_8->s1_11;
s1_1->s1_8;
s1_5->s1_8;
s1_11->final;
s1_10->final;
}
###
