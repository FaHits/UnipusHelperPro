package org.unipus.unipus;

/* (っ*´Д`)っ 小代码要被看光啦 */

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.util.Random;

/**
 * 人类作答节奏：按题型给一个耗时区间，提交前随机等待一段时间。
 * <p>
 * 目的：不再「秒提交」，避免触发平台的提交冷却，也让学习记录更像真人操作。
 * <p>
 * 注意：U 校园的「学习时长」由官方播放器写入，答案提交接口不会写时长
 * （2026-11-02 实测：等待 120 秒再提交、在 body 里附 duration，单元/叶子节点的
 * duration 均保持 0）。所以本类只控制节奏，不声称能增加学习时长。
 */
public final class TimingPolicy {

    private static final Logger logger = LogManager.getLogger(TimingPolicy.class);

    private static final Random RNG = new Random();

    /** 全局节奏倍率：1.0 为标准，改小整体变快，改大整体变慢。 */
    private static final double MULTIPLIER = 1.0;

    private TimingPolicy() {
    }

    /**
     * 某题型的一次作答耗时区间（秒）。
     * 阅读/看视频类的区间比客观题长，写作类最长。
     */
    private static int[] rangeOf(CourseDetail.Node.BaseType type) {
        if (type == null) {
            return new int[]{20, 60};
        }
        return switch (type) {
            case RICH_TEXT_READ -> new int[]{90, 240};
            case TEXT_LEARN -> new int[]{45, 150};
            case VIDEO_POINT_READ -> new int[]{120, 300};
            case VIDEO_POPUP -> new int[]{60, 180};
            case VOCABULARY -> new int[]{40, 120};
            case INPUT -> new int[]{25, 80};
            case SINGLE_CHOICE, MULTICHOICE -> new int[]{12, 45};
            case MATERIAL_BANKED_CLOZE -> new int[]{30, 90};
            case SEQUENCE -> new int[]{20, 60};
            case BASIC_SCOOP_CONTENT -> new int[]{20, 70};
            case SHORT_ANSWER -> new int[]{60, 180};
            case TRANSLATION -> new int[]{90, 240};
            case WRITING -> new int[]{150, 420};
            default -> new int[]{20, 60};
        };
    }

    /**
     * 本次提交前应等待的毫秒数：在题型区间内取随机值，再乘全局倍率。
     */
    public static long nextDelayMs(CourseDetail.Node.BaseType type) {
        int[] range = rangeOf(type);
        int span = Math.max(1, range[1] - range[0]);
        double seconds = (range[0] + RNG.nextDouble() * span) * MULTIPLIER;
        long ms = Math.round(seconds * 1000);
        logger.debug("TimingPolicy: type={} delay={} ms", type, ms);
        return ms;
    }

    /** 等待期间显示给用户的说明。 */
    public static String describe(long millis) {
        return String.format("按真人节奏作答 %d 秒", Math.max(1, Math.round(millis / 1000.0)));
    }
}
