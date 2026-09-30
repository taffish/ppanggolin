# PPanGGOLiN 执行 fixture

本目录脚本生成五个确定性的合成微生物基因组，不来自真实生物样本。
基因家族由固定字符串 SHA512 构造，包含 persistent、shell、cloud 和可变岛，
用于触发聚类、分区、RGP、spot、module 与 rgp_cluster，不作生物正确性证据。
同时生成 GFF3、GenBank、FASTA 与对应两列列表，路径故意带空格。

每个 smoke 模式独立创建私有 scratch，退出时清理；不得复用前一 smoke 的产物。
运行日志由上游 stderr 与失败时有限的日志尾部保留。identity 会核对
固定模型文件和原始许可 inventory。Dockerfile 不执行完整分析或浏览器渲染。

GenBank 路径专门覆盖 2.3.2 新 gb-io 解析；GEXF 通过 NetworkX 独立读取；
all 模式是真实上游 all，再调用新版 RGP 聚类，不是其余 smoke 模式的缩写。
静态 HTML 的浏览器显示/交互验收另由维护者记录，文件存在不能替代 GUI 验证。
