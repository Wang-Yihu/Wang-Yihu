## Hi there 👋

<!--
**Wang-Yihu/Wang-Yihu** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->
chouqihuire_snerdihp_youdongneng.py就是我用728的那个实验文档设计的抽气回热计算
反应堆功率1000000; 发电机功率207000
我其实是想用它计算一下如果想达到设计文档的水平，那m_dot_rated_c还有m_dot_rated_t还有eff_t应该设置多少

chouqihuire_snerdihp.py其实数据和chouqihuire_snerdihp_youdongneng.py差不多，只是已知量用的是MOOSE的逻辑，即p0_1, T0_1, p_6, omega

huanreqi.i是一个套管式换热器的算例，方程在输入卡的备注里

open_brayton_cycle_copy.i就是开式无抽气回热布雷顿来建立728模型的例子，由于没有抽气回热器，里面的热源其实是原定的反应堆功率1000000再加上抽气回热器功率836098.0899443103

recuperator_brayton_cycle.i就是根据那几个python来建立的抽气回热布雷顿，但是很难控制最终状态稳定在什么情况，而且达成稳态时的各个参数都太奇怪了

jac.massflowrate_3eqn_water97_myself.i是我自己写的单管摩擦压降，但是结果和轴向控制体关系很大，怀疑MOOSE不能很好地算这个东西。
