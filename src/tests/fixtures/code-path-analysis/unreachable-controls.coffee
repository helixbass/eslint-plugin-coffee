### eslint-disable ###
###expected
initial->s2_1->s2_2->s2_3->s2_4->s2_3;
s2_4->s2_5;
s2_1->final;
###
###expected
initial->s1_1->final;
###
->
  return

  return
  throw new Error()
  while yes
    continue
    break
###DOT
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s2_1[label="FunctionExpression\nBlockStatement\nReturnStatement\nReturnStatement:exit"];
s2_2[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nReturnStatement\nThrowStatement\nNewExpression\nIdentifier (Error)\nWhileStatement\nReturnStatement:exit\nIdentifier:exit (Error)\nNewExpression:exit\nThrowStatement:exit"];
s2_3[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nLiteral (true)\nLiteral:exit (true)"];
s2_4[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nBlockStatement\nContinueStatement\nBreakStatement\nContinueStatement:exit\nBreakStatement:exit\nBlockStatement:exit"];
s2_5[style="rounded,dashed,filled",fillcolor="#FF9800",label="<<unreachable>>\nWhileStatement:exit\nBlockStatement:exit\nFunctionExpression:exit"];
initial->s2_1->s2_2->s2_3->s2_4->s2_3;
s2_4->s2_5;
s2_1->final;
}
digraph {
node[shape=box,style="rounded,filled",fillcolor=white];
initial[label="",shape=circle,style=filled,fillcolor=black,width=0.25,height=0.25];
final[label="",shape=doublecircle,style=filled,fillcolor=black,width=0.25,height=0.25];
s1_1[label="Program\nExpressionStatement\nFunctionExpression\nFunctionExpression:exit\nExpressionStatement:exit\nProgram:exit"];
initial->s1_1->final;
}
###
